require 'minitest/autorun'
require 'minitest/pride'
require 'date'
require 'minitest/ci'
require_relative '../lib/premium_calculator'

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

class QuoteTest < Minitest::Test
  def test_gender_is_required
    quote = Quote.new(gender: "")
    assert_equal(false, quote.valid?)
    assert_equal(true, quote.errors[:gender].any?)
    assert_match(/can't be blank/, quote.errors[:gender].first)
  end

  def test_gender_is_valid
    quote = Quote.new
    %w(F M).each do |gender|
      quote.gender = gender
      quote.valid?
      assert_equal(false, quote.errors[:gender].any?)
    end
  end

  def test_gender_is_invalid
    quote = Quote.new
    %w(f m U u Female Male Unknown).each do |gender|
      quote.gender = gender
      quote.valid?
      assert_equal(true, quote.errors[:gender].any?)
      assert_match(/is not included in the list/, quote.errors[:gender].first)
    end
  end

  def test_date_of_birth_is_required
    quote = Quote.new(date_of_birth: nil)
    quote.valid?
    assert_equal(true, quote.errors[:date_of_birth].any?)
    assert_match(/can't be blank/, quote.errors[:date_of_birth].first)
  end

  def test_date_of_birth_is_invalid
    quote = Quote.new(date_of_birth: 19900816) 
    quote.valid?
    assert_equal(true, quote.errors[:date_of_birth].any?)
    assert_match(/is an invalid date/, quote.errors[:date_of_birth].first)
  end

  def test_date_of_birth_is_valid
    quote = Quote.new(date_of_birth: Date.parse("1990-08-16"))
    quote.valid?
    assert_equal(false, quote.errors[:date_of_birth].any?)
  end

  def test_smoking_status_is_required
    quote = Quote.new(smoking_status: "")
    quote.valid?
    assert_equal(true, quote.errors[:smoking_status].any?)
    assert_match(/can't be blank/, quote.errors[:smoking_status].first) 
  end

  def test_smoking_status_is_invalid
    quote = Quote.new
    %w(X Y No Yes Non-Smoker Smoker).each do |smoking_status|
      quote.smoking_status = smoking_status
      quote.valid?
      assert_equal(true, quote.errors[:smoking_status].any?)
      assert_match(/is not included in the list/, quote.errors[:smoking_status].first)
    end
  end

  def test_smoking_status_is_valid
    quote = Quote.new
    %w(N S).each do |smoking_status|
      quote.smoking_status = smoking_status
      quote.valid?
      assert_equal(false, quote.errors[:smoking_status].any?)
    end
  end

  def test_coverage_amount_is_required
    quote = Quote.new(coverage_amount: nil)
    quote.valid?
    assert_equal(true, quote.errors[:coverage_amount].any?)
  end

  def test_coverage_amount_is_less_than_minimum
    quote = Quote.new
    %w(-100_000 0 9_999.99).each do |amount|
      coverage_amount = amount.to_f
      quote.coverage_amount = coverage_amount
      quote.valid?
      assert_equal(true, quote.errors[:coverage_amount].any?)
      assert_match(/must be greater than or equal to/, quote.errors[:coverage_amount].first)
    end
  end

  def test_coverage_amount_is_more_than_maximum
    quote = Quote.new
    %w(10_000_000.01 50_000_000 100_000_000).each do |amount|
      quote.coverage_amount = amount.to_f
      quote.valid?
      assert_equal(true, quote.errors[:coverage_amount].any?)
      assert_match(/must be less than or equal to/, quote.errors[:coverage_amount].first)
    end
  end  

  def test_effective_date_is_required
    quote = Quote.new(effective_date: nil)
    quote.valid?
    assert_equal(true, quote.errors[:effective_date].any?)
    assert_match(/can't be blank/, quote.errors[:effective_date].first)
  end

  def test_effective_date_is_invalid
    quote = Quote.new
    dates = [19900816, "1990-08-16", "August 16, 1990", "16 August 1990"]
    dates.each do |date|
      quote.effective_date = date
      quote.valid?
      assert_equal(true, quote.errors[:effective_date].any?)
      assert_match(/is an invalid date/, quote.errors[:effective_date].first)
    end
  end

  def test_effective_date_is_valid
    quote = Quote.new
    dates = ["19900816", "1990-08-16", "August 16, 1990", "16 August 1990"]
    dates.each do |date|
      quote.effective_date = Date.parse(date)
      quote.valid?
      assert_equal(false, quote.errors[:effective_date].any?)
    end
  end

  def test_plan_code_is_required
    quote = Quote.new(plan_code: "")
    quote.valid?
    assert_equal(true, quote.errors[:plan_code].any?)
    assert_match(/can't be blank/, quote.errors[:plan_code].first)
  end

  def test_plan_code_is_invalid
    quote = Quote.new
    plan_codes = ['ABC', 'XYZ', 'Term', 'Whole Life', 'Medical']
    plan_codes.each do |plan_code|
      quote.plan_code = plan_code
      quote.valid?
      assert_equal(true, quote.errors[:plan_code].any?)
      assert_match(/is not included in the list/, quote.errors[:plan_code].first)
    end
  end

  def test_plan_code_is_valid
    quote = Quote.new
    plan_codes = %w(T15)
    plan_codes.each do |plan_code|
      quote.plan_code = plan_code
      quote.valid?
      assert_equal(false, quote.errors[:plan_code].any?)
    end
  end

  def test_coverage_terms_is_required
    quote = Quote.new
    quote.valid?
    assert_equal(true, quote.errors[:coverage_terms].any?)
    assert_match(/can't be blank/, quote.errors[:coverage_terms].first)
    quote.coverage_terms = nil
    quote.valid?
    assert_equal(true, quote.errors[:coverage_terms].any?)
    assert_match(/can't be blank/, quote.errors[:coverage_terms].first)
  end

  def test_coverage_terms_is_not_numeric
    quote = Quote.new
    coverage_terms = ["15", "Fifteen"]
    coverage_terms.each do |terms|
      quote.coverage_terms = terms
      quote.valid?
      assert_equal(true, quote.errors[:coverage_terms].any?)
      assert_match(/is not a number/, quote.errors[:coverage_terms].first)
    end
  end

  def test_coverage_terms_is_numeric
    quote = Quote.new
    coverage_terms = [5, 10, 15, 20, 25, 30]
    coverage_terms.each do |terms|
      quote.coverage_terms = terms
      quote.valid?
      assert_equal(false, quote.errors[:coverage_terms].any?)
    end
  end

  def test_coverage_terms_is_not_integer
    quote = Quote.new
    coverage_terms = [5.0, 15.5, 29.99]
    coverage_terms.each do |terms|
      quote.coverage_terms = terms
      quote.valid?
      assert_equal(true, quote.errors[:coverage_terms].any?)
      assert_match(/must be an integer/, quote.errors[:coverage_terms].first)
    end
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
    assert_equal(false, age.birthday?)
  end

  def test_birthday_on_one_day_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                           now: Date.parse("2021-01-02"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_on_same_day_one_month_before
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2020-12-01"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_on_same_day_one_month_after
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2021-02-01"))
    assert_equal(false, age.birthday?)
  end

  def test_birthday_passed_on_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2021-01-01"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_one_day_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-01-18"),
                            now: Date.parse("2021-01-17"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_one_day_after_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-01-18"),
                              now: Date.parse("2021-01-19"))
    assert_equal(true, age.birthday_passed?)
  end

  def test_birthday_passed_on_previous_month_before_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-02-19"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_next_month_after_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-04-17"))
    assert_equal(true, age.birthday_passed?)
  end
end

class AgeLastBirthdayTest < Minitest::Test
  def test_actual_age_on_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-03-18"))
    assert_equal(18, age.age)
  end

  def test_actual_age_on_one_day_before_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-03-17"))
    assert_equal(17, age.age)
  end

  def test_actual_age_on_one_day_after_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-03-19"))
    assert_equal(18, age.age)
  end

  def test_actual_age_on_previous_month_before_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-02-19"))
    assert_equal(17, age.age)
  end

  def test_actual_age_on_next_month_after_birthday
    age = AgeLastBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-04-17"))
    assert_equal(18, age.age)
  end
end

class AgeNextBirthdayTest < Minitest::Test
  def test_age_on_birthday
    age = AgeNextBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-03-18"))
    assert_equal(19, age.age)
  end

  def test_age_on_one_day_before_birthday
    age = AgeNextBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-03-17"))
    assert_equal(18, age.age)
  end

  def test_age_on_one_day_after_birthday
    age = AgeNextBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-03-19"))
    assert_equal(19, age.age)
  end

  def test_age_on_previous_month_before_birthday
    age = AgeNextBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-02-19"))
    assert_equal(18, age.age)
  end

  def test_age_on_next_month_after_birthday
    age = AgeNextBirthday.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-04-17"))
    assert_equal(19, age.age)
  end
end

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

class ModalFactorTest < Minitest::Test
  def test_modal_factor_t15_yearly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(1.0000, modal_factor.yearly)
  end

  def test_modal_factor_t15_half_yearly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(0.5065, modal_factor.half_yearly)
  end

  def test_modal_factor_t15_quarterly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(0.2565, modal_factor.quarterly)
  end

  def test_modal_factor_t15_monthly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(0.0865, modal_factor.monthly)
  end
end

class TermBasedRateTest < Minitest::Test
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

    error = assert_raises(ArgumentError) { TermBasedRate.new(quote: @quote) }
    assert_match(/smoking status/i, error.message)
  end

  def test_rate_unknown_gender
    @quote.gender = "X"

    error = assert_raises(ArgumentError) { TermBasedRate.new(quote: @quote) }
    assert_match(/gender/i, error.message)
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

    error = assert_raises(ArgumentError) { TermBasedRate.new(quote: @quote) }
    assert_match(/plan code/i, error.message)
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

class AgeBasedRateTest < Minitest::Test
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

    error = assert_raises(ArgumentError) { AgeBasedRate.new(quote: @quote) }
    assert_match(/smoking status/i, error.message)
  end

  def test_rate_unknown_gender
    @quote.gender = "X"

    error = assert_raises(ArgumentError) { AgeBasedRate.new(quote: @quote) }
    assert_match(/gender/i, error.message)
  end

  def test_divisor_plan_wlf
    age_based_rate = AgeBasedRate.new(quote: @quote)
    expected = 100_000.00
    assert_equal(expected, age_based_rate.divisor)
  end

  def test_divisor_invalid_plan
    @quote.plan_code = "YYY"

    error = assert_raises(ArgumentError) { AgeBasedRate.new(quote: @quote) }
    assert_match(/plan code/i, error.message)
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