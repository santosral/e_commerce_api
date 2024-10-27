module Products
  class TrackMetricsJob
    include Sidekiq::Worker

    def perform(product_id, metric)
      product = Product.find(product_id)

      case metric
      when "add_to_cart_count"
        product.increment_metrics("add_to_cart_count")
        Products::ApplyPriceAdjustmentRuleJob.perform_async(product_id, "cart_demand")
      when "order_count"
        product.increment_metrics("order_count")
        Products::ApplyPriceAdjustmentRuleJob.perform_async(product_id, "order_demand")
      end
    rescue StandardError => e
      Rails.logger.error("Failed to update metrics for product #{product_id}: #{e.message}")
    end
  end
end
