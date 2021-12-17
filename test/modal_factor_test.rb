require_relative 'test_helper'
require_relative '../lib/modal_factor'
require_relative '../lib/life_insurance_plan'

class ModalFactorTest < Minitest::Test
  def test_modal_factor_t15_yearly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(1.0000, modal_factor.yearly)
  end

  def test_modal_factor_t15_half_yearly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(0.5065, modal_factor.half_yearly)
  end

  def test_modal_factor_t15_quarterly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(0.2565, modal_factor.quarterly)
  end

  def test_modal_factor_t15_monthly
    modal_factor = ModalFactor.new(plan_code: LifeInsurancePlan::T15)
    assert_equal(0.0865, modal_factor.monthly)
  end
end
