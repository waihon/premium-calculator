class ModalFactor
  YEARLY = "Y".freeze
  HALF_YEARLY = "HY".freeze
  QUARTERLY = "Q".freeze
  MONTHLY = "M".freeze

  attr_reader :plan_code

  def initialize(plan_code:)
    @plan_code = plan_code
  end

  def modal_factor
    filename = "config/modal_factor.yaml"
    return nil unless File.exist?(filename)
    @modal_factor ||= YAML.load(File.read(filename))
  end

  def yearly
    modal_factor[plan_code][YEARLY]
  end

  def half_yearly
    modal_factor[plan_code][HALF_YEARLY] 
  end

  def quarterly
    modal_factor[plan_code][QUARTERLY]
  end

  def monthly
    modal_factor[plan_code][MONTHLY] 
  end
end