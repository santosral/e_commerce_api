require "http_clients/competitor_client"
require "bigdecimal"

module Prices
  class FetchCompetitorPricesJob
    include Sidekiq::Job

    def perform(args)
      competitor_prices = CompetitorClient.fetch_prices
      return unless competitor_prices

      adjustment_rule = Prices::AdjustmentRule.find(args["id"])
      competitor_price_map = competitor_prices.each_with_object({}) do |price_info, hash|
        hash[price_info["name"].strip.downcase] = price_info["price"]
      end

      adjustment_rule.products.each do |product|
        competitor_price = BigDecimal(competitor_price_map[product.name.strip.downcase].to_s)
        current_price = product.current_price
        next if current_price.amount < competitor_price

        calculated_amount = 0.0
        case adjustment_rule.competitor_rule
        when "match"
          calculated_amount = competitor_price
        when "undercut"
          calculated_amount = competitor_price * adjustment_rule.factor
        end

        product.price_adjustments.build(pricing_strategy: "competitor", adjustment_rule_time_frame: adjustment_rule.time_frame, amount: calculated_amount)

        if product.save!
          Rails.logger.info("Updated price for product #{product.name} to #{competitor_price}")
        else
          Rails.logger.warn("No competitor price found for product #{product.name}")
        end
      end
    rescue StandardError => e
      Rails.logger.error("Failed to update price for product #{product_id}: #{e.message}")
    end
  end
end
