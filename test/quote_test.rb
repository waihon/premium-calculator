require_relative 'test_helper'
require_relative '../lib/quote'

class QuoteTest < Minitest::Test
  def test_gender_is_required
    quote = Quote.new
    ["", nil].each do |gender|
      quote.gender = gender
      assert_equal(false, quote.valid?)
      assert_equal(true, quote.error?(attr: :gender))
      assert_match(/can't be blank/, quote.first_error_message(attr: :gender))
    end
  end

  def test_gender_is_valid
    quote = Quote.new
    %w(F M).each do |gender|
      quote.gender = gender
      quote.valid?
      assert_equal(false, quote.error?(attr: :gender))
    end
  end

  def test_gender_is_invalid
    quote = Quote.new
    %w(f m U u Female Male Unknown).each do |gender|
      quote.gender = gender
      quote.valid?
      assert_equal(true, quote.error?(attr: :gender))
      assert_match(/is not included in the list/, quote.first_error_message(attr: :gender))
    end
  end

  def test_date_of_birth_is_required
    quote = Quote.new(date_of_birth: nil)
    quote.valid?
    assert_equal(true, quote.error?(attr: :date_of_birth))
    assert_match(/can't be blank/, quote.first_error_message(attr: :date_of_birth))
  end

  def test_date_of_birth_is_invalid
    quote = Quote.new(date_of_birth: 19900816) 
    quote.valid?
    assert_equal(true, quote.error?(attr: :date_of_birth))
    assert_match(/is an invalid date/, quote.first_error_message(attr: :date_of_birth))
  end

  def test_date_of_birth_is_valid
    quote = Quote.new(date_of_birth: Date.parse("1990-08-16"))
    quote.valid?
    assert_equal(false, quote.error?(attr: :date_of_birth))
  end

  def test_smoking_status_is_required
    quote = Quote.new
    ["", nil].each do |smoking_status|
      quote.smoking_status = smoking_status
      quote.valid?
      assert_equal(true, quote.error?(attr: :smoking_status))
      assert_match(/can't be blank/, quote.first_error_message(attr: :smoking_status))
    end
  end

  def test_smoking_status_is_invalid
    quote = Quote.new
    %w(X Y No Yes Non-Smoker Smoker).each do |smoking_status|
      quote.smoking_status = smoking_status
      quote.valid?
      assert_equal(true, quote.error?(attr: :smoking_status))
      assert_match(/is not included in the list/, quote.first_error_message(attr: :smoking_status))
    end
  end

  def test_smoking_status_is_valid
    quote = Quote.new
    %w(N S).each do |smoking_status|
      quote.smoking_status = smoking_status
      quote.valid?
      assert_equal(false, quote.error?(attr: :smoking_status))
    end
  end

  def test_coverage_amount_is_required
    quote = Quote.new(coverage_amount: nil)
    quote.valid?
    assert_equal(true, quote.error?(attr: :coverage_amount))
  end

  def test_coverage_amount_is_less_than_minimum
    quote = Quote.new
    %w(-100_000 0 9_999.99).each do |amount|
      coverage_amount = amount.to_f
      quote.coverage_amount = coverage_amount
      quote.valid?
      assert_equal(true, quote.error?(attr: :coverage_amount))
      assert_match(/must be greater than or equal to/, quote.first_error_message(attr: :coverage_amount))
    end
  end

  def test_coverage_amount_is_more_than_maximum
    quote = Quote.new
    %w(10_000_000.01 50_000_000 100_000_000).each do |amount|
      quote.coverage_amount = amount.to_f
      quote.valid?
      assert_equal(true, quote.error?(attr: :coverage_amount))
      assert_match(/must be less than or equal to/, quote.first_error_message(attr: :coverage_amount))
    end
  end  

  def test_effective_date_is_required
    quote = Quote.new(effective_date: nil)
    quote.valid?
    assert_equal(true, quote.error?(attr: :effective_date))
    assert_match(/can't be blank/, quote.first_error_message(attr: :effective_date))
  end

  def test_effective_date_is_invalid
    quote = Quote.new
    dates = [19900816, "1990-08-16", "August 16, 1990", "16 August 1990"]
    dates.each do |date|
      quote.effective_date = date
      quote.valid?
      assert_equal(true, quote.error?(attr: :effective_date))
      assert_match(/is an invalid date/, quote.first_error_message(attr: :effective_date))
    end
  end

  def test_effective_date_is_valid
    quote = Quote.new
    dates = ["19900816", "1990-08-16", "August 16, 1990", "16 August 1990"]
    dates.each do |date|
      quote.effective_date = Date.parse(date)
      quote.valid?
      assert_equal(false, quote.error?(attr: :effective_date))
    end
  end

  def test_plan_code_is_required
    quote = Quote.new
    ["", nil].each do |plan_code|
      quote.plan_code = plan_code
      quote.valid?
      assert_equal(true, quote.error?(attr: :plan_code))
      assert_match(/can't be blank/, quote.first_error_message(attr: :plan_code))
    end
  end

  def test_plan_code_is_invalid
    quote = Quote.new
    plan_codes = ['ABC', 'XYZ', 'Term', 'Whole Life', 'Medical']
    plan_codes.each do |plan_code|
      quote.plan_code = plan_code
      quote.valid?
      assert_equal(true, quote.error?(attr: :plan_code))
      assert_match(/is not included in the list/, quote.first_error_message(attr: :plan_code))
    end
  end

  def test_plan_code_is_valid
    quote = Quote.new
    plan_codes = %w(T15)
    plan_codes.each do |plan_code|
      quote.plan_code = plan_code
      quote.valid?
      assert_equal(false, quote.error?(attr: :plan_code))
    end
  end

  def test_coverage_terms_is_required
    quote = Quote.new
    quote.valid?
    assert_equal(true, quote.error?(attr: :coverage_terms))
    assert_match(/can't be blank/, quote.first_error_message(attr: :coverage_terms))
    quote.coverage_terms = nil
    quote.valid?
    assert_equal(true, quote.error?(attr: :coverage_terms))
    assert_match(/can't be blank/, quote.first_error_message(attr: :coverage_terms))
  end

  def test_coverage_terms_is_not_numeric
    quote = Quote.new
    coverage_terms = ["15", "Fifteen"]
    coverage_terms.each do |terms|
      quote.coverage_terms = terms
      quote.valid?
      assert_equal(true, quote.error?(attr: :coverage_terms))
      assert_match(/is not a number/, quote.first_error_message(attr: :coverage_terms))
    end
  end

  def test_coverage_terms_is_numeric
    quote = Quote.new
    coverage_terms = [5, 10, 15, 20, 25, 30]
    coverage_terms.each do |terms|
      quote.coverage_terms = terms
      quote.valid?
      assert_equal(false, quote.error?(attr: :coverage_terms))
    end
  end

  def test_coverage_terms_is_not_integer
    quote = Quote.new
    coverage_terms = [5.0, 15.5, 29.99]
    coverage_terms.each do |terms|
      quote.coverage_terms = terms
      quote.valid?
      assert_equal(true, quote.error?(attr: :coverage_terms))
      assert_match(/must be an integer/, quote.first_error_message(attr: :coverage_terms))
    end
  end

  def test_persisted_is_false
    quote = Quote.new
    assert_equal(false, quote.persisted?)
  end
end
