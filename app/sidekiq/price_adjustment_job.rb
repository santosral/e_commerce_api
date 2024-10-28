class PriceAdjustmentJob
  include Sidekiq::Job

  def perform(product_id, time_frame, strategy_type)
    product = Product.find(product_id)

    service = PriceAdjustmentService.new(product, time_frame: time_frame, strategy_type: strategy_type)
    service.call
  rescue StandardError => e
    Rails.logger.error("Failed to update price for product #{product_id}: #{e.message}")
  end
end
