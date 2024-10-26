require "bigdecimal"

module BigDecimalExtensions
  def formatted_amount
    self.round(2).to_s("F")
  end
end
