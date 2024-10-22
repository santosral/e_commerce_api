json.extract! price_history, :id, :product_id, :amount, :effective_date, :created_at, :updated_at
json.url price_history_url(price_history, format: :json)
