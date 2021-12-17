require 'date'
require_relative 'test_helper'
require_relative '../lib/premium_calculator'
require_relative 'rate_role_test'

class PremiumCalculatorTest < Minitest::Test
  def setup
    @original_stdout = $stdout.clone
    $stdout.reopen File.new('/dev/null', 'w')

    @quote = Quote.new(
      gender: Gender::FEMALE,
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: Smoking::NON_SMOKER,
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01"),
      plan_code: LifeInsurancePlan::T15,
      coverage_terms: 15
    )

    @age_based_quote = Quote.new(
      gender: Gender::FEMALE,
      date_of_birth: Date.parse("2000-01-01"),
      smoking_status: Smoking::NON_SMOKER,
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01"),
      plan_code: LifeInsurancePlan::WLF,
      coverage_terms: 64
    )
  end

  def teardown
    $stdout.reopen @original_stdout
  end

  def test_premium_female_non_smoker
    calculator = PremiumCalculator.new(quote: @quote)
    expected = 80
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_female_smoker
    @quote.smoking_status = Smoking::SMOKER

    calculator = PremiumCalculator.new(quote: @quote)
    expected = 107
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_male_non_smoker
    @quote.gender = Gender::MALE

    calculator = PremiumCalculator.new(quote: @quote)
    expected = 108
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_male_smoker
    @quote.gender = Gender::MALE
    @quote.smoking_status = Smoking::SMOKER

    calculator = PremiumCalculator.new(quote: @quote)
    expected = 153
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_higher_coverage_amount
    @quote.coverage_amount = 150_000

    calculator = PremiumCalculator.new(quote: @quote)
    expected = 120
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_earlier_date_of_birth
    @quote.date_of_birth = Date.parse("1961-01-01")

    calculator = PremiumCalculator.new(quote: @quote)
    expected = 934 
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_female_non_smoker_unfound_age
    @quote.date_of_birth = Date.parse("2004-01-01")

    calculator = PremiumCalculator.new(quote: @quote)
    assert_nil(calculator.premium_amount)
  end

  def test_premium_female_unknown_smoking_status
    @quote.smoking_status = "X"

    error = assert_raises(ArgumentError) { PremiumCalculator.new(quote: @quote) }
    assert_match(/smoking status/i, error.message)
  end

  def test_premium_unknown_gender
    @quote.gender = "X"

    error = assert_raises(ArgumentError) { PremiumCalculator.new(quote: @quote) }
    assert_match(/gender/i, error.message)
  end

  def test_age_based_premium_female_non_smoker
    calculator = PremiumCalculator.new(quote: @age_based_quote)
    expected = 2036
    assert_equal(expected, calculator.premium_amount)
  end

  def test_age_based_premium_female_smoker
    @age_based_quote.smoking_status = Smoking::SMOKER

    calculator = PremiumCalculator.new(quote: @age_based_quote)
    expected = 2069
    assert_equal(expected, calculator.premium_amount)
  end

  def test_age_based_premium_male_non_smoker
    @age_based_quote.gender = Gender::MALE

    calculator = PremiumCalculator.new(quote: @age_based_quote)
    expected = 2413
    assert_equal(expected, calculator.premium_amount)
  end

  def test_age_based_premium_male_smoker
    @age_based_quote.gender = Gender::MALE
    @age_based_quote.smoking_status = Smoking::SMOKER

    calculator = PremiumCalculator.new(quote: @age_based_quote)
    expected = 2501
    assert_equal(expected, calculator.premium_amount)
  end

  def test_age_based_premium_higher_coverage_amount
    @age_based_quote.coverage_amount = 150_000

    calculator = PremiumCalculator.new(quote: @age_based_quote)
    expected = 3054
    assert_equal(expected, calculator.premium_amount)
  end

  def test_age_based_premium_earlier_date_of_birth
    @age_based_quote.date_of_birth = Date.parse("1961-01-01")

    calculator = PremiumCalculator.new(quote: @age_based_quote)
    expected = 7847
    assert_equal(expected, calculator.premium_amount)
  end  

  def test_age_based_premium_female_non_smoker_unfound_age
    ["2006-01-01", "1960-01-01"].each do |date|
      @age_based_quote.date_of_birth = Date.parse(date)

      calculator = PremiumCalculator.new(quote: @age_based_quote)
      assert_nil(calculator.premium_amount)
    end
  end

  def test_age_based_premium_female_unknown_smoking_status
    @age_based_quote.smoking_status = "X"

    error = assert_raises(ArgumentError) { PremiumCalculator.new(quote: @age_based_quote) }
    assert_match(/smoking status/i, error.message)
  end

  def test_age_based_premium_unknown_gender
    @quote.gender = "X"

    error = assert_raises(ArgumentError) { PremiumCalculator.new(quote: @quote) }
    assert_match(/gender/i, error.message)
  end
end

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

    term_based_rate = TermBasedRate.new(quote: @quote)
    assert_nil(term_based_rate.divisor) 
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