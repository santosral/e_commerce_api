Rails.application.config.after_initialize do
  BigDecimal.include(BigDecimalExtensions)
end
