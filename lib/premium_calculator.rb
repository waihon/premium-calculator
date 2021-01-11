require 'yaml'

class PremiumCalculator
  attr_reader :quote

  def initialize(quote:)
    @quote = quote
  end

  def premium_amount
    age = AgeCalculator.new(date_of_birth: quote.date_of_birth, now: quote.effective_date)
    premium_rate = PremiumRate.new(gender: quote.gender,
                                   smoking_status: quote.smoking_status,
                                   age: age.current)
    begin
      quote.coverage_amount * premium_rate.rate / rate_divisor
    rescue PremiumRateNotFoundError => e
      puts "#{e.message} for #{e.key}"
    end
  end

  def rate_divisor
    100_000.0
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
  attr_reader :plan_code

  def initialize(gender:, date_of_birth:, smoking_status:,
                 coverage_amount:, effective_date: Date.today,
                 plan_code: "T15")
    @gender = gender
    @date_of_birth = date_of_birth
    @smoking_status = smoking_status
    @coverage_amount = coverage_amount
    @effective_date = effective_date
    @plan_code = plan_code
  end
end

class PremiumRate
  attr_reader :gender, :smoking_status, :age, :plan_code

  def initialize(gender:, smoking_status:, age:, plan_code: "T15")
    @gender = gender
    @smoking_status = smoking_status
    @age = age
    @plan_code = plan_code
  end

  def rate
    rates = YAML.load(File.read("config/#{plan_code}/premium_rates.yaml"))

    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :gender) unless rates[gender]
    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :smoking_status) unless rates[gender][smoking_status]
    raise PremiumRateNotFoundError.new("Premium Rate Not Found", :age) unless rates[gender][smoking_status][age]

    rates[gender][smoking_status][age]
  end
end

class PremiumRateNotFoundError < StandardError
  attr_reader :key

  def initialize(message, key)
    super(message)

    @key = key
  end
end

class PremiumRates
  attr_reader :plan_code, :rates

  def initialize(plan_code:)
    @plan_code = plan_code
  end

  def rates
    filename = "config/#{plan_code}/premium_rates.yaml"
    return nil unless File.exists?(filename)
    @rates ||= YAML.load(filename)
  end
end

class ModalFactor
  attr_reader :plan_code

  def initialize(plan_code:)
    @plan_code = plan_code
  end

  def yearly
    1.0000
  end

  def half_yearly
    0.5065
  end

  def quarterly
    0.2565
  end

  def monthly
    0.0865
  end
end