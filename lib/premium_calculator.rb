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
    case gender
    when "F"
      case smoking_status
      when "N"
        80
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
end