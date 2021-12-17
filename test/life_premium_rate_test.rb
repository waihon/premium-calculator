require_relative 'test_helper'
require_relative 'rate_role_test'
require_relative '../lib/life_premium_rate'
require_relative '../lib/quote'
require_relative '../lib/gender'
require_relative '../lib/smoking'

class LifePremiumRateTest < Minitest::Test
  include RateRoleTest

  def setup
    @quote = Quote.new(
      gender: Gender::FEMALE,
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: Smoking::NON_SMOKER,
      plan_code: "XXX".freeze,
      effective_date: Date.parse("2021-01-01"),
      coverage_amount: 100_000,
      coverage_terms: 15
    )
    @role_player = LifePremiumRate.new(quote: @quote)
  end

  def test_premium_rate_factory
    assert_equal(true, LifePremiumRate.handles?(plan_code: @quote.plan_code))
  end

  def test_rate_not_implemented
    life_premium_rate = LifePremiumRate.new(quote: @quote)
    assert_raises(NotImplementedError) { life_premium_rate.rate }
  end
end
