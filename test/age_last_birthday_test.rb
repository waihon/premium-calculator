require_relative 'test_helper'
require_relative 'age_role_test'
require_relative '../lib/age_last_birthday'

class AgeLastBirthdayTest < Minitest::Test
  include AgeRoleTest

  def setup
    @role_player = AgeLastBirthday.new(date_of_birth: Date.parse("2003-01-01"),
                                       now: Date.parse("2021-01-01"))
  end

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
