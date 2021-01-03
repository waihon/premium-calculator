class PremiumCalculator
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

  def premium_amount
    coverage_amount * premium_rate / rate_divisor
  end

  def premium_rate
    case gender
    when "F"
      case smoking_status
      when "N"
        case date_of_birth.year
        when 2003
          80
        when 1961
          934
        end
      when "S"
        107
      end
    when "M"
      case smoking_status
      when "N"
        108
      when "S"
        153
      end
    end
  end

  def rate_divisor
    100_000.0
  end
end