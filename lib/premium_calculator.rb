require 'yaml'
require 'active_model'
require_relative 'life_insurance_plan'
require_relative 'gender'
require_relative 'smoking'
require_relative 'age'
require_relative 'age_last_birthday'
require_relative 'age_next_birthday'
require_relative 'age_nearest_birthday'
require_relative 'date_validator'
require_relative 'numeric_validator'
require_relative 'quote'
require_relative 'life_premium_rate'

class PremiumCalculator
  attr_reader :quote, :age, :premium_rate

  def initialize(quote:)
    unless quote.valid?
      raise ArgumentError, "invalid quote object: #{quote.first_full_message}"
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
