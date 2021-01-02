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
end