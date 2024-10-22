json.extract! cart_item, :id, :quantity, :captured_price_id, :created_at, :updated_at
json.url cart_item_url(cart_item, format: :json)

json.product do
  json.partial! "products/product", product: cart_item.product
end
