class Trend
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cart_additions_count, type: Integer, default: 0
  field :orders_count, type: Integer, default: 0
  field :recorded_at, type: DateTime, default: Time.zone.now

  belongs_to :product

  def self.aggregate_historical_data(product_id:, start_date:, end_date: Time.zone.now)
    results = collection.aggregate([
      {
        "$match": {
          "product_id": product_id,
          "recorded_at": { "$gte": start_date, "$lte": end_date }
        }
      },
      {
        "$group": {
          "_id": nil,
          "total_cart_additions": { "$sum": "$cart_additions_count" },
          "total_orders": { "$sum": "$orders_count" }
        }
      }
    ]).first

    results || { total_cart_additions: 0, total_orders: 0 }
  end

  def self.aggregate_by_timeframe(product:, time_frame:, date: Time.zone.now)
    time_frame = TimeFrame.dates(time_frame)

    aggregate_historical_data(product_id: product.id, start_date: time_frame[:start_date], end_date: time_frame[:end_date])
  end

  def self.increment_daily_trend(product:, type:)
    current_time = Time.zone.now
    trend = where(product: product, recorded_at: current_time.beginning_of_day...current_time.end_of_day).first_or_initialize

    case type
    when "cart_additions_count"
      trend.cart_additions_count += 1
    when "orders_count"
      trend.orders_count += 1
    else
      raise ArgumentError, "Invalid type: #{type}"
    end

    trend.save!
    trend
  end
end
