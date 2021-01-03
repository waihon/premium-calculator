require 'minitest/autorun'
require 'minitest/pride'
require 'date'
require_relative '../lib/premium_calculator'

class PremiumCalculatorTest < Minitest::Test
  def test_premium_female_non_smoker
    calculator = PremiumCalculator.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    expected = 80
    assert_equal expected, calculator.premium_amount
  end

  def test_premium_female_smoker
    calculator = PremiumCalculator.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "S",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    expected = 107
    assert_equal expected, calculator.premium_amount
  end

  def test_premium_male_non_smoker
    calculator = PremiumCalculator.new(
      gender: "M",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    expected = 108
    assert_equal expected, calculator.premium_amount
  end

  def test_premium_male_smoker
    calculator = PremiumCalculator.new(
      gender: "M",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "S",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    expected = 153
    assert_equal expected, calculator.premium_amount
  end

  def test_premium_higher_coverage_amount
    calculator = PremiumCalculator.new(
      gender: "F",
      date_of_birth: Date.parse("2003-01-01"),
      smoking_status: "N",
      coverage_amount: 150_000,
      effective_date: Date.parse("2021-01-01")
    )
    expected = 120
    assert_equal expected, calculator.premium_amount
  end

  def test_premium_earlier_date_of_birth
    calculator = PremiumCalculator.new(
      gender: "F",
      date_of_birth: Date.parse("1961-01-01"),
      smoking_status: "N",
      coverage_amount: 100_000,
      effective_date: Date.parse("2021-01-01")
    )
    expected = 934 
    assert_equal expected, calculator.premium_amount
  end
end

class AgeTest < Minitest::Test
  def test_birthday_on_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                  now: Date.parse("2021-01-01"))
    assert_equal true, age.birthday?
  end

  def test_birthday_on_one_day_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                  now: Date.parse("2020-12-31"))
    assert_equal false, age.birthday?
  end

  def test_birthday_on_one_day_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                  now: Date.parse("2021-01-02"))
    assert_equal false, age.birthday?
  end

  def test_birthday_on_same_day_one_month_before
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                  now: Date.parse("2020-12-01"))
    assert_equal false, age.birthday?
  end

  def test_birthday_on_same_day_one_month_after
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                  now: Date.parse("2021-02-01"))
    assert_equal false, age.birthday?
  end

  def test_birthday_passed_on_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                  now: Date.parse("2021-01-01"))
    assert_equal false, age.birthday_passed?
  end

  def test_birthday_passed_on_one_day_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-18"),
                  now: Date.parse("2021-01-17"))
    assert_equal false, age.birthday_passed?
  end

  def test_birthday_passed_on_one_day_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-18"),
                  now: Date.parse("2021-01-19"))
    assert_equal true, age.birthday_passed?
  end

  def test_birthday_passed_on_previous_month_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-02-19"))
    assert_equal false, age.birthday_passed?
  end

  def test_birthday_passed_on_next_month_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-04-17"))
    assert_equal true, age.birthday_passed?
  end

  def test_current_age_on_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-03-18"))
    assert_equal 18, age.current
  end

  def test_current_age_on_one_day_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-03-17"))
    assert_equal 17, age.current
  end

  def test_current_age_on_one_day_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-03-19"))
    assert_equal 18, age.current
  end

  def test_current_age_on_previous_month_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-02-19"))
    assert_equal 17, age.current
  end

  def test_current_age_on_next_month_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-04-17"))
    assert_equal 18, age.current
  end

  def test_next_age_on_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-03-18"))
    assert_equal 19, age.next
  end

  def test_next_age_on_one_day_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-03-17"))
    assert_equal 18, age.next
  end

  def test_next_age_on_one_day_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-03-19"))
    assert_equal 19, age.next
  end

  def test_next_age_on_previous_month_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                  now: Date.parse("2021-02-19"))
    assert_equal 18, age.next
  end
end