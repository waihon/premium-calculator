class LifeInsurancePlan
  T15 = "T15".freeze
  WLF = "WLF".freeze

  def self.active_plans
    [T15, WLF].freeze
  end
end