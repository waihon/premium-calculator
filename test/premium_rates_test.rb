require_relative 'test_helper'
require_relative '../lib/premium_rates'
require_relative '../lib/life_insurance_plan'

class PremiumRatesTest < Minitest::Test
  def test_premXum_rates_valid_plan
    rates = PremiumRates.new(plan_code: LifeInsurancePlan::T15).rates
    refute_nil(rates)
  end

  def test_premium_rates_invalid_plan
    rates = PremiumRates.new(plan_code: "XXX").rates
    assert_nil(rates)
  end
end
