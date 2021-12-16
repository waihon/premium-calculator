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
require_relative 'term_based_rate'
require_relative 'age_based_rate'
require_relative 'premium_rate_not_found_error'
require_relative 'premium_rates'
require_relative 'modal_factor'

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
