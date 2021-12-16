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