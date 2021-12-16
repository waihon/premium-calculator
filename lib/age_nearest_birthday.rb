class AgeNearestBirthday < Age
  def age
    return actual_age if birthday?

    year_of_last_birthday = birthday_passed? ? now.year : now.year - 1
    year_of_next_birthday = year_of_last_birthday + 1

    last_birthday = Date.new(year_of_last_birthday, date_of_birth.month, date_of_birth.day)
    next_birthday = Date.new(year_of_next_birthday, date_of_birth.month, date_of_birth.day)

    days_in_a_year = (next_birthday - last_birthday).to_f
    days_from_last_birthday = (now - last_birthday).to_f
    fraction_of_a_year = days_from_last_birthday / days_in_a_year

    actual_age + (fraction_of_a_year >= 0.50000000 ? 1 : 0)
  end
end