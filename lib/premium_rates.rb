class PremiumRates
  attr_reader :plan_code

  def initialize(plan_code:)
    @plan_code = plan_code
    filename = "config/#{@plan_code}/premium_rates.yaml"
    @premium_rates = File.exist?(filename) ? YAML.load(File.read(filename)) : nil
  end

  def rates
    @premium_rates && @premium_rates["rates"]
  end

  def divisor
    @premium_rates && @premium_rates['divisor']
  end
end
