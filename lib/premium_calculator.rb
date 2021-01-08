require 'yaml'

class PremiumCalculator
  attr_reader :quote

  def initialize(quote:)
    @quote = quote
  end

  def premium_amount
    age = AgeCalculator.new(date_of_birth: quote.date_of_birth, now: quote.effective_date)
    age = Age.new(date_of_birth: quote.date_of_birth, now: quote.effective_date)
    premium_rate = PremiumRate.new(gender: quote.gender,
                                   smoking_status: quote.smoking_status,
                                   age: age.current)
    quote.coverage_amount * premium_rate.rate / rate_divisor
  end

  def rate_divisor
    100_000.0
  end
end

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

  def current
    current_age = now.year - date_of_birth.year
    current_age -= 1 unless (birthday? || birthday_passed?)
    current_age
  end

  def next
    current + 1
  end
end

class AgeCalculator
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

  def current
    current_age = now.year - date_of_birth.year
    current_age -= 1 unless (birthday? || birthday_passed?)
    current_age
  end

  def next
    current + 1
  end
end

class Quote
  attr_reader :gender, :date_of_birth, :smoking_status
  attr_reader :coverage_amount, :effective_date

  def initialize(gender:, date_of_birth:, smoking_status:,
                 coverage_amount:, effective_date: Date.today)
    @gender = gender
    @date_of_birth = date_of_birth
    @smoking_status = smoking_status
    @coverage_amount = coverage_amount
    @effective_date = effective_date
  end
end

class PremiumRate
  attr_reader :gender, :smoking_status, :age

  def initialize(gender:, smoking_status:, age:)
    @gender = gender
    @smoking_status = smoking_status
    @age = age
  end

  def rate
    rates = YAML.load(File.read("config/premium_rates.yaml"))
    rates[gender][smoking_status][age]
  end
end