json.extract! price, :id, :amount, :pricing_strategy, :valid_from, :valid_until, :created_at, :updated_at
json.url price_url(price, format: :json)
