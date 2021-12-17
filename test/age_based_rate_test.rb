require_relative 'test_helper'
require_relative 'rate_role_test'
require_relative '../lib/age_based_rate'
require_relative '../lib/quote'
require_relative '../lib/gender'
require_relative '../lib/smoking'
require_relative '../lib/life_insurance_plan'
require_relative '../lib/age_next_birthday'
require_relative '../lib/premium_rate_not_found_error'

class AgeBasedRateTest < Minitest::Test
  include RateRoleTest

  def setup
    @quote = Quote.new(
      gender: Gender::FEMALE,
      date_of_birth: Date.parse("2000-01-01"),
      smoking_status: Smoking::NON_SMOKER,
      plan_code: LifeInsurancePlan::WLF,
      effective_date: Date.parse("2021-01-01"),
      coverage_amount: 100_000,
      coverage_terms: 64
    )
    @role_player = AgeBasedRate.new(quote: @quote)
  end

  def test_rate_female_non_smoker
    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 2036
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_female_smoker
    @quote.smoking_status = Smoking::SMOKER

    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 2069
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_male_non_smoker
    @quote.gender = Gender::MALE

    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 2413
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_male_smoker
    @quote.gender = Gender::MALE
    @quote.smoking_status = Smoking::SMOKER

    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 2501
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_female_non_smoker_higher_age
    @quote.date_of_birth = Date.parse("1961-01-01")
    @quote.coverage_terms = 25

    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 7847
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_female_non_smoker_unfound_age
    @quote.date_of_birth = Date.parse("1960-01-01")
    @quote.coverage_terms = 24

    age_based_rate = AgeBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { age_based_rate.rate }
    assert_equal(:age, error.key)
  end

  def test_rate_female_unknown_smoking_status
    @quote.smoking_status = "X"

    age_based_rate = AgeBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { age_based_rate.rate }
    assert_equal(:smoking_status, error.key)
  end

  def test_rate_unknown_gender
    @quote.gender = "X"

    age_based_rate = AgeBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { age_based_rate.rate }
    assert_equal(:gender, error.key)
  end

  def test_divisor_plan_wlf
    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 100_000.00
    assert_equal(expected, age_based_rate.divisor)
  end

  def test_divisor_invalid_plan
    @quote.plan_code = "YYY"

    age_based_rate = AgeBasedRate.new(quote: @quote)
    assert_nil(age_based_rate.divisor) 
  end

  def test_rate_female_non_smoker_age_next_birthday
    age_based_rate = AgeBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 2085
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_female_smoker_age_next_birthday
    @quote.smoking_status = Smoking::SMOKER

    age_based_rate = AgeBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 2118
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_male_non_smoker_age_next_birthday
    @quote.gender = Gender::MALE

    age_based_rate = AgeBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 2462
    assert_equal(expected, age_based_rate.rate)
  end

  def test_rate_male_smoker_age_next_birthday
    @quote.gender = Gender::MALE
    @quote.smoking_status = Smoking::SMOKER

    age_based_rate = AgeBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 2550
    assert_equal(expected, age_based_rate.rate)
  end
end
