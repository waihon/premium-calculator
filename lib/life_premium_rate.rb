require_relative 'age_last_birthday'
require_relative 'premium_rates'

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
      #raise ArgumentError, "invalid quote object: #{quote.first_full_message}"
    end

    @quote = quote
    @age = age_calculator.new(date_of_birth: quote.date_of_birth, now: quote.effective_date)
    @premium_rates = premium_rates.new(plan_code: quote.plan_code)
  end

  def rate
    raise NotImplementedError, "Called abstract method: rate"
  end

  def divisor
    @premium_rates.divisor
  end
end
