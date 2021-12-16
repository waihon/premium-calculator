class Age
  attr_reader :date_of_birth, :now

  def initialize(date_of_birth:, now: Date.today)
    @date_of_birth = date_of_birth
    @now = now
  end

  def birthday?
    date_of_birth.month == now.month && date_of_birth.day == now.day
  end

  def birthday_passed?
    (now.month > date_of_birth.month) ||
    (now.month == date_of_birth.month && now.day > date_of_birth.day)
  end

  def actual_age
    age = now.year - date_of_birth.year
    age -= 1 unless (birthday? || birthday_passed?)
    age
  end

  def age
    raise NotImplementedError, "Called abstract method: age"
  end
end