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
    coverage_amount * premium_rate
  end

  def premium_rate
    case gender
    when "F"
      case smoking_status
      when "N"
        case date_of_birth.year
        when 2003
          0.0008 
        when 1961
          0.00934
        end
      when "S"
        0.00107 
      end
    when "M"
      case smoking_status
      when "N"
        0.00108 
      when "S"
        0.00153 
      end
    end
  end

  def rate_divisor
    1.0
  end
end