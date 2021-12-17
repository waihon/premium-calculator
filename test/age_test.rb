require_relative 'test_helper'
require_relative 'age_role_test'
require_relative '../lib/age'

class AgeTest < Minitest::Test
  include AgeRoleTest

  def setup
    @role_player = Age.new(date_of_birth: Date.parse("2003-01-01"),
                           now: Date.parse("2021-01-01"))
  end

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
    age = Age.new(date_of_birth: Date.parse("2003-01-18"),
                              now: Date.parse("2021-01-19"))
    assert_equal(true, age.birthday_passed?)
  end

  def test_birthday_passed_on_previous_month_before_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-02-19"))
    assert_equal(false, age.birthday_passed?)
  end

  def test_birthday_passed_on_next_month_after_birthday
    age = Age.new(date_of_birth: Date.parse("2003-03-18"),
                              now: Date.parse("2021-04-17"))
    assert_equal(true, age.birthday_passed?)
  end

  def test_age_not_implemented
    age = Age.new(date_of_birth: Date.parse("2003-01-01"),
                            now: Date.parse("2021-01-01"))
    assert_raises(NotImplementedError) { age.age }
  end
end
