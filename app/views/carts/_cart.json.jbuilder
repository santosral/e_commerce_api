json.extract! cart, :id
json.total_price cart.total_price.formatted_amount
json.url cart_url(cart, format: :json)
json.cart_items cart.cart_items do |cart_item|
  json.partial! "cart_items/cart_item", cart_item: cart_item
end
