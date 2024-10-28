json.extract! cart, :id
json.total_price cart.total_price.formatted_amount
json.url cart_url(cart, format: :json)
