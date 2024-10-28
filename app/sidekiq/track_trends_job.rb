class TrackTrendsJob
  include Sidekiq::Job

  def perform(product_id, time_frame, trend)
    product = Product.find(product_id)

    case trend
    when "cart_additions_count"
      Trend.increment_daily_trend(product: product, type: "cart_additions_count")
      PriceAdjustmentJob.perform_async(product_id, time_frame, "cart_demand")
    when "orders_count"
      Trend.increment_daily_trend(product: product, type: "orders_count")
      PriceAdjustmentJob.perform_async(product_id, time_frame, "order_demand")
    end
  rescue StandardError => e
    Rails.logger.error("Failed to update metrics for product #{product_id}: #{e.message}")
  end
end
