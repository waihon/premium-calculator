require_relative 'life_premium_rate'
require_relative 'term_based_rate'
require_relative 'age_based_rate'
require_relative 'premium_rate_not_found_error'

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
