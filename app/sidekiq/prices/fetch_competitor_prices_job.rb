require "sidekiq-scheduler"

module Prices
  class FetchCompetitorPricesJob
    include Sidekiq::Job

    def perform(price_adjustment_rule_id)
      adjustment_rule = Prices::AdjustmentRule.find(product_id)

      adjustment_rule.products.each do |product|
        product.apply_price_adjustment_rules_by("competitor")
      end
    rescue StandardError => e
      Rails.logger.error("Failed to update price for product #{product_id}: #{e.message}")
    end
  end
end
