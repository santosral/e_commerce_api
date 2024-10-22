json.extract! trend_tracker, :id, :product_id, :add_to_cart_count, :order_count, :created_at, :updated_at
json.url trend_tracker_url(trend_tracker, format: :json)
