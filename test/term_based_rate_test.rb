require_relative 'test_helper'
require_relative 'rate_role_test'
require_relative '../lib/quote'
require_relative '../lib/gender'
require_relative '../lib/smoking'
require_relative '../lib/life_insurance_plan'
require_relative '../lib/term_based_rate'
require_relative '../lib/age_next_birthday'

class TermBasedRateTest < Minitest::Test
  include RateRoleTest

  def setup
    @quote = Quote.new(
      gender: Gender::FEMALE,
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: Smoking::NON_SMOKER,
      plan_code: LifeInsurancePlan::T15,
      effective_date: Date.parse("2021-01-01"),
      coverage_amount: 100_000,
      coverage_terms: 15
    )
    @role_player = TermBasedRate.new(quote: @quote)
  end

  def test_rate_female_non_smoker
    term_based_rate = TermBasedRate.new(quote: @quote)
    expected = 80
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_female_smoker
    @quote.smoking_status = Smoking::SMOKER

    term_based_rate = TermBasedRate.new(quote: @quote)
    expected = 107
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_male_non_smoker
    @quote.gender = Gender::MALE

    term_based_rate = TermBasedRate.new(quote: @quote)
    expected = 108
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_male_smoker
    @quote.gender = Gender::MALE
    @quote.smoking_status = Smoking::SMOKER

    term_based_rate = TermBasedRate.new(quote: @quote)
    expected = 153
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_female_non_smoker_higher_age
    @quote.date_of_birth = Date.parse("1961-01-01")

    term_based_rate = TermBasedRate.new(quote: @quote)
    expected = 934
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_female_non_smoker_unfound_age
    @quote.date_of_birth = Date.parse("1960-01-01")

    term_based_rate = TermBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { term_based_rate.rate }
    assert_equal(:age, error.key)
  end

  def test_rate_female_unknown_smoking_status
    @quote.smoking_status = "X"

    term_based_rate = TermBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { term_based_rate.rate }
    assert_equal(:smoking_status, error.key)
  end

  def test_rate_unknown_gender
    @quote.gender = "X"

    term_based_rate = TermBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { term_based_rate.rate }
    assert_equal(:gender, error.key)
  end

  def test_rate_unfound_coverage_terms
    @quote.coverage_terms = 16

    term_based_rate = TermBasedRate.new(quote: @quote)
    error = assert_raises(PremiumRateNotFoundError) { term_based_rate.rate }
    assert_equal(:coverage_terms, error.key)
  end

  def test_divisor_plan_t15
    term_based_rate = TermBasedRate.new(quote: @quote)
    expected = 100_000.00
    assert_equal(expected, term_based_rate.divisor)
  end

  def test_divisor_invalid_plan
    @quote.plan_code = "XXX"

    term_based_rate = TermBasedRate.new(quote: @quote)
    assert_nil(term_based_rate.divisor) 
  end

  def test_rate_female_non_smoker_age_next_birthday
    term_based_rate = TermBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 81
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_female_smoker_age_next_birthday
    @quote.smoking_status = Smoking::SMOKER

    term_based_rate = TermBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 109
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_male_non_smoker_age_next_birthday
    @quote.gender = Gender::MALE

    term_based_rate = TermBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 109
    assert_equal(expected, term_based_rate.rate)
  end

  def test_rate_male_smoker_age_next_birthday
    @quote.gender = Gender::MALE
    @quote.smoking_status = Smoking::SMOKER

    term_based_rate = TermBasedRate.new(quote: @quote, age_calculator: AgeNextBirthday)
    expected = 156
    assert_equal(expected, term_based_rate.rate)
  end
end
