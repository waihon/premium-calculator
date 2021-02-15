require 'yaml'
require 'active_model'

class LifeInsurancePlan
  T15 = "T15".freeze
  WLF = "WLF".freeze

  def self.active_plans
    [T15, WLF].freeze
  end
end

class Gender
  MALE = "M".freeze
  FEMALE = "F".freeze
end

class Smoking
  NON_SMOKER = "N".freeze
  SMOKER = "S".freeze
end

class PremiumCalculator
  attr_reader :quote, :age, :premium_rate

  def initialize(quote:)
    unless quote.valid?
      raise ArgumentError, "invalid quote object: #{quote.errors.full_messages[0]}"
    end
    @quote = quote
    @premium_rate = LifePremiumRate.for(quote: quote)
  end

  def premium_amount
    begin
      quote.coverage_amount * premium_rate.rate / premium_rate.divisor 
    rescue PremiumRateNotFoundError => e
      puts "#{e.message} for #{e.key}"
    end
  end
end

class Age
  attr_reader :date_of_birth, :now

  def initialize(date_of_birth:, now: Date.today)
    @date_of_birth = date_of_birth
    @now = now
  end

  def birthday?
    date_of_birth.month == now.month && date_of_birth.day == now.day
  end

  def birthday_passed?
    (now.month > date_of_birth.month) ||
    (now.month == date_of_birth.month && now.day > date_of_birth.day)
  end

  def age
    age = now.year - date_of_birth.year
    age -= 1 unless (birthday? || birthday_passed?)
    age
  end
end

class AgeLastBirthday < Age
  def age
    age = now.year - date_of_birth.year
    age -= 1 unless (birthday? || birthday_passed?)
    age
  end
end

class AgeNextBirthday < Age
  def age
    super + 1
  end
end

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.respond_to?(:strftime) 
      record.errors.add(attribute, options[:message] || "is an invalid date")
    end
  end
end

class NumericValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a? Numeric
      record.errors.add(attribute, options[:message] || "is not a number")
    end
  end
end

class Quote
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :gender, :date_of_birth, :smoking_status
  attr_accessor :coverage_amount, :effective_date
  attr_accessor :plan_code, :coverage_terms

  validates :gender, presence: true
  validates :gender, inclusion: { in: [Gender::FEMALE, Gender::MALE] }
  validates :date_of_birth, presence: true
  validates :date_of_birth, date: true
  validates :smoking_status, presence: true
  validates :smoking_status, inclusion: { in: [Smoking::NON_SMOKER, Smoking::SMOKER] }
  validates :coverage_amount, presence: true
  validates :coverage_amount, numericality: { greater_than_or_equal_to: 10_000,
                                              less_than_or_equal_to: 10_000_000 }
  validates :effective_date, presence: true
  validates :effective_date, date: true
  validates :plan_code, presence: true
  validates :plan_code, inclusion: { in: LifeInsurancePlan.active_plans }
  validates :coverage_terms, presence: true
  validates :coverage_terms, numeric: true
  validates :coverage_terms, numericality: { only_integer: true }

  def initialize(attributes={})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end  
end

class LifePremiumRate
  def self.for(quote:, age_calculator: AgeLastBirthday, premium_rates: PremiumRates)
    registry.find do |candidate|
      candidate.handles?(plan_code: quote.plan_code)
    end.new(quote: quote, age_calculator: age_calculator, premium_rates: premium_rates)
  end

  def self.registry
    @registry ||= [LifePremiumRate]
  end

  def self.register(candidate:)
    registry.prepend(candidate)
  end

  def self.inherited(candidate)
    register(candidate: candidate)
  end

  def self.handles?(plan_code:)
    true
  end

  def initialize(quote:, age_calculator: AgeLastBirthday, premium_rates: PremiumRates)
    unless quote.valid?
      raise ArgumentError, "invalid quote object: #{quote.errors.full_messages[0]}"
    end

    @quote = quote
    @age = age_calculator.new(date_of_birth: quote.date_of_birth, now: quote.effective_date)
    @premium_rates = premium_rates.new(plan_code: quote.plan_code)
  end

  def rate
    raise "Called abstract method: rate" 
  end

  def divisor
    @premium_rates.divisor
  end
end

class TermBasedRate < LifePremiumRate
  def self.handles?(plan_code:)
    [LifeInsurancePlan::T15].include?(plan_code)
  end

  def rate 
    rates = @premium_rates.rates
    coverage_terms = @quote.coverage_terms
    gender = @quote.gender
    smoking_status = @quote.smoking_status
    age = @age.age

    unless rates[coverage_terms]
      raise PremiumRateNotFoundError.new("premium rate not found", :coverage_terms)
    end
    unless rates[coverage_terms][gender]
      raise PremiumRateNotFoundError.new("premium rate not found", :gender)
    end
    unless rates[coverage_terms][gender][smoking_status]
      raise PremiumRateNotFoundError.new("premium rate not found", :smoking_status) 
    end
    unless rates[coverage_terms][gender][smoking_status][age]
      raise PremiumRateNotFoundError.new("premium rate not found", :age)
    end

    rates[coverage_terms][gender][smoking_status][age]
  end
end

class AgeBasedRate < LifePremiumRate
  def self.handles?(plan_code:)
    [LifeInsurancePlan::WLF].include?(plan_code)
  end

  def rate
    rates = @premium_rates.rates
    gender = @quote.gender
    smoking_status = @quote.smoking_status
    age = @age.age

    unless rates[gender]
      raise PremiumRateNotFoundError.new("premium rate not found", :gender)
    end
    unless rates[gender][smoking_status]
      raise PremiumRateNotFoundError.new("premium rate not found", :smoking_status)
    end
    unless rates[gender][smoking_status][age]
      raise PremiumRateNotFoundError.new("premium rate not found", :age)
    end

    rates[gender][smoking_status][age]
  end
end

class PremiumRateNotFoundError < StandardError
  attr_reader :key

  def initialize(message, key)
    super(message)

    @key = key
  end
end

class PremiumRates
  attr_reader :plan_code

  def initialize(plan_code:)
    @plan_code = plan_code
    filename = "config/#{@plan_code}/premium_rates.yaml"
    @premium_rates = File.exist?(filename) ? YAML.load(File.read(filename)) : nil
  end

  def rates
    @premium_rates && @premium_rates["rates"]
  end

  def divisor
    @premium_rates && @premium_rates['divisor']
  end
end

class ModalFactor
  YEARLY = "Y".freeze
  HALF_YEARLY = "HY".freeze
  QUARTERLY = "Q".freeze
  MONTHLY = "M".freeze

  attr_reader :plan_code

  def initialize(plan_code:)
    @plan_code = plan_code
  end

  def modal_factor
    filename = "config/modal_factor.yaml"
    return nil unless File.exist?(filename)
    @modal_factor ||= YAML.load(File.read(filename))
  end

  def yearly
    modal_factor[plan_code][YEARLY]
  end

  def half_yearly
    modal_factor[plan_code][HALF_YEARLY] 
  end

  def quarterly
    modal_factor[plan_code][QUARTERLY]
  end

  def monthly
    modal_factor[plan_code][MONTHLY] 
  end
end
