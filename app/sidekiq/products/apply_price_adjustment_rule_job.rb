module Products
  class ApplyPriceAdjustmentRuleJob
    include Sidekiq::Worker

    def perform(product_id, strategy_type)
      product = Product.find(product_id)

      product.apply_price_adjustment_rules_by(strategy_type)
    rescue StandardError => e
      Rails.logger.error("Failed to update price for product #{product_id}: #{e.message}")
    end
  end
end
