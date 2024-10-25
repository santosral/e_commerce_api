json.extract! cart, :id, :total_price
json.url cart_url(cart, format: :json)
