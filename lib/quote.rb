class Quote
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :gender, :date_of_birth, :smoking_status
  attr_accessor :coverage_amount, :effective_date
  attr_accessor :plan_code, :coverage_terms

  validates :gender, presence: true
  validates :gender, inclusion: { in: [Gender::FEMALE, Gender::MALE] }
  validates :date_of_birth, presence: true
  validates :date_of_birth, date: true
  validates :smoking_status, presence: true
  validates :smoking_status, inclusion: { in: [Smoking::NON_SMOKER, Smoking::SMOKER] }
  validates :coverage_amount, presence: true
  validates :coverage_amount, numericality: { greater_than_or_equal_to: 10_000,
                                              less_than_or_equal_to: 10_000_000 }
  validates :effective_date, presence: true
  validates :effective_date, date: true
  validates :plan_code, presence: true
  validates :plan_code, inclusion: { in: LifeInsurancePlan.active_plans }
  validates :coverage_terms, presence: true
  validates :coverage_terms, numeric: true
  validates :coverage_terms, numericality: { only_integer: true }

  def initialize(attributes={})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end  

  def error?(attr:)
    errors[attr].any?
  end

  def first_full_message
    errors.full_messages[0]
  end

  def first_error_message(attr:)
    errors[attr].first
  end
end
