require_relative 'age'

class AgeNextBirthday < Age
  def age
    actual_age + 1
  end
end
