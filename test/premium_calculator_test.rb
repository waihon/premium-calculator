require 'minitest/autorun'
require 'minitest/pride'
require 'date'
require_relative '../lib/premium_calculator'

class PremiumCalculatorTest < Minitest::Test
  def test_premium_female_non_smoker
    quote = Quote.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    expected = 80
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_female_smoker
    quote = Quote.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "S",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    expected = 107
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_male_non_smoker
    quote = Quote.new(
      gender: "M",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    expected = 108
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_male_smoker
    quote = Quote.new(
      gender: "M",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "S",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    expected = 153
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_higher_coverage_amount
    quote = Quote.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 150_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    expected = 120
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_earlier_date_of_birth
    quote = Quote.new(
      gender: "F",
      date_of_birth: Date.parse("1961-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    expected = 934 
    assert_equal(expected, calculator.premium_amount)
  end

  def test_premium_female_non_smoker_unfound_age
    quote = Quote.new(
      gender: "F",
      date_of_birth: Date.parse("2004-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    assert_nil(calculator.premium_amount)
  end

  def test_premium_female_unknown_smoking_status
    quote = Quote.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "X",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    assert_nil(calculator.premium_amount)
  end

  def test_premium_unknown_gender
    quote = Quote.new(
      gender: "X",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    calculator = PremiumCalculator.new(quote: quote)
    assert_nil(calculator.premium_amount)
  end
end

class AgeCalculatorTest < Minitest::Test
  def test_birthday_on_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2021-01-01"))
    assert_equal true, age.birthday?
  end

  def test_birthday_on_one_day_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2020-12-31"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_on_one_day_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-01"),
                           now: Date.parse("2021-01-02"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_on_same_day_one_month_before
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2020-12-01"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_on_same_day_one_month_after
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2021-02-01"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_passed_on_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2021-01-01"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_one_day_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-18"),
                            now: Date.parse("2021-01-17"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_one_day_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-01-18"),
                            now: Date.parse("2021-01-19"))
    assert_equal(true, age.birthday_passed?)
  end

  def test_birthday_passed_on_previous_month_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-02-19"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_next_month_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-04-17"))
    assert_equal(true, age.birthday_passed?)
  end

  def test_current_age_on_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-03-18"))
    assert_equal(18, age.current)
  end

  def test_current_age_on_one_day_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-03-17"))
    assert_equal(17, age.current)
  end

  def test_current_age_on_one_day_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-03-19"))
    assert_equal(18, age.current)
  end

  def test_current_age_on_previous_month_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-02-19"))
    assert_equal(17, age.current)
  end

  def test_current_age_on_next_month_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-04-17"))
    assert_equal(18, age.current)
  end

  def test_next_age_on_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-03-18"))
    assert_equal(19, age.next)
  end

  def test_next_age_on_one_day_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-03-17"))
    assert_equal(18, age.next)
  end

  def test_next_age_on_one_day_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-03-19"))
    assert_equal(19, age.next)
  end

  def test_next_age_on_previous_month_before_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-02-19"))
    assert_equal(18, age.next)
  end

  def test_next_age_on_next_month_after_birthday
    age = AgeCalculator.new(date_of_birth: Date.parse("2003-03-18"),
                            now: Date.parse("2021-04-17"))
    assert_equal(19, age.next)
  end
end

class PremiumRateTest < Minitest::Test
  def test_rate_female_non_smoker
    premium_rate = PremiumRate.new(
      gender: "F",
      smoking_status: "N",
      age: 18,
      plan_code: "T15"
    )
    expected = 80
    assert_equal(expected, premium_rate.rate)
  end

  def test_rate_female_smoker
    premium_rate = PremiumRate.new(
      gender: "F",
      smoking_status: "S",
      age: 18
    )
    expected = 107
    assert_equal(expected, premium_rate.rate)
  end

  def test_rate_male_non_smoker
    premium_rate = PremiumRate.new(
      gender: "M",
      smoking_status: "N",
      age: 18
    )
    expected = 108
    assert_equal(expected, premium_rate.rate)
  end

  def test_rate_male_smoker
    premium_rate = PremiumRate.new(
      gender: "M",
      smoking_status: "S",
      age: 18
    )
    expected = 153
    assert_equal(expected, premium_rate.rate)
  end

  def test_rate_female_non_smoker_higher_age
    premium_rate = PremiumRate.new(
      gender: "F",
      smoking_status: "N",
      age: 60
    )
    expected = 934 
    assert_equal(expected, premium_rate.rate)
  end

  def test_rate_female_non_smoker_unfound_age
    premium_rate = PremiumRate.new(
      gender: "F",
      smoking_status: "N",
      age: 61
    )
    error = assert_raises(PremiumRateNotFoundError) { premium_rate.rate }
    assert_equal(:age, error.key)
  end

  def test_rate_female_unknown_smoking_status
    premium_rate = PremiumRate.new(
      gender: "F",
      smoking_status: "X",
      age: 18
    )
    error = assert_raises(PremiumRateNotFoundError) { premium_rate.rate }
    assert_equal(:smoking_status, error.key)
  end

  def test_rate_unknown_gender
    premium_rate = PremiumRate.new(
      gender: "X",
      smoking_status: "N",
      age: 18
    )
    error = assert_raises(PremiumRateNotFoundError) { premium_rate.rate }
    assert_equal(:gender, error.key)
  end
end

class PremiumRatesTest < Minitest::Test
  def test_premium_rates_valid_plan
    rates = PremiumRates.new(plan_code: "T15").rates
    refute_nil(rates)
  end

  def test_premium_rates_invalid_plan
    rates = PremiumRates.new(plan_code: "XXX").rates
    assert_nil(rates)
  end
end

class ModalFactorTest < Minitest::Test
  def test_modal_factor_t15_yearly
    modal_factor = ModalFactor.new(plan_code: "T15")
    assert_equal(1.0000, modal_factor.yearly)
  end

  def test_modal_factor_t15_half_yearly
    modal_factor = ModalFactor.new(plan_code: "T15")
    assert_equal(0.5065, modal_factor.half_yearly)
  end

  def test_modal_factor_t15_quarterly
    modal_factor = ModalFactor.new(plan_code: "T15")
    assert_equal(0.2565, modal_factor.quarterly)
  end

  def test_modal_factor_t15_monthly
    modal_factor = ModalFactor.new(plan_code: "T15")
    assert_equal(0.0865, modal_factor.monthly)
  end
end