require_relative 'life_premium_rate'

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
