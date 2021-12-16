class PremiumRateNotFoundError < StandardError
  attr_reader :key

  def initialize(message, key)
    super(message)

    @key = key
  end
end