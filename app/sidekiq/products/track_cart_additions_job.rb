module Products
  class TrackCartAdditionsJob
    include Sidekiq::Worker

    def perform(product_id)
      product = Product.find(product_id)

      product.increase_cart_metrics
      product.apply_price_adjustment_rules_by_demand
    rescue StandardError => e
      Rails.logger.error("Failed to update metrics for product #{product_id}: #{e.message}")
    end
  end
end
