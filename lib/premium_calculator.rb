require 'yaml'
require 'active_model'

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

class AgeCalculator
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

  def current
    current_age = now.year - date_of_birth.year
    current_age -= 1 unless (birthday? || birthday_passed?)
    current_age
  end

  def next
    current + 1
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
  validates :gender, inclusion: { in: %w(F M) }
  validates :date_of_birth, presence: true
  validates :date_of_birth, date: true
  validates :smoking_status, presence: true
  validates :smoking_status, inclusion: { in: %w(N S) }
  validates :coverage_amount, presence: true
  validates :coverage_amount, numericality: { greater_than_or_equal_to: 10_000,
                                              less_than_or_equal_to: 10_000_000 }
  validates :effective_date, presence: true
  validates :effective_date, date: true
  validates :plan_code, presence: true
  validates :plan_code, inclusion: { in: %w(T15) }
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

class PremiumRate
  attr_reader :gender, :smoking_status, :age, :plan_code
  attr_reader :coverage_terms, :premium_rates

  def initialize(gender:, smoking_status:, age:, plan_code:,
    coverage_terms:)
    @gender = gender
    @smoking_status = smoking_status
    @age = age
    @plan_code = plan_code
    @coverage_terms = coverage_terms
  end

  def premium_rates
    @premium_rates ||= PremiumRates.new(plan_code: plan_code)
  end

  def rate
    rates = premium_rates.rates

    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :coverage_terms) unless rates[coverage_terms]
    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :gender) unless rates[coverage_terms][gender]
    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :smoking_status) unless rates[coverage_terms][gender][smoking_status]
    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :age) unless rates[coverage_terms][gender][smoking_status][age]

    rates[coverage_terms][gender][smoking_status][age]
  end

  def divisor
    premium_rates.divisor
  end
end

class LifePremiumRate
  def self.for(quote:)
    case quote.plan_code
    when "T15"
      TermBasedRate
    else
      LifePremiumRate
    end.new(quote: quote)
  end

  def initialize(quote:)
    unless quote.valid?
      raise ArgumentError, "invalid quote object: #{quote.errors.full_messages[0]}"
    end

    @quote = quote
    @age = AgeCalculator.new(date_of_birth: quote.date_of_birth, now: quote.effective_date)
    @premium_rates = PremiumRates.new(plan_code: quote.plan_code)
  end

  def rate
    raise "Called abstract method: rate" 
  end

  def divisor
    @premium_rates.divisor
  end
end

class TermBasedRate < LifePremiumRate
  def rate 
    rates = @premium_rates.rates
    coverage_terms = @quote.coverage_terms
    gender = @quote.gender
    smoking_status = @quote.smoking_status
    age = @age.current

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

class PremiumRateNotFoundError < StandardError
  attr_reader :key

  def initialize(message, key)
    super(message)

    @key = key
  end
end

class PremiumRates
  attr_reader :plan_code, :rates

  def initialize(plan_code:)
    @plan_code = plan_code
    filename = "config/#{@plan_code}/premium_rates.yaml"
    @premium_rates = File.exists?(filename) ? YAML.load(File.read(filename)) : nil
  end

  def rates
    @premium_rates && @premium_rates["rates"]
  end

  def divisor
    @premium_rates && @premium_rates['divisor']
  end
end

class ModalFactor
  attr_reader :plan_code

  def initialize(plan_code:)
    @plan_code = plan_code
  end

  def modal_factor
    filename = "config/modal_factor.yaml"
    return nil unless File.exists?(filename)
    @modal_factor ||= YAML.load(File.read(filename))
  end

  def yearly
    modal_factor[plan_code]["Y"]
  end

  def half_yearly
    modal_factor[plan_code]["HY"] 
  end

  def quarterly
    modal_factor[plan_code]["Q"] 
  end

  def monthly
    modal_factor[plan_code]["M"] 
  end
end