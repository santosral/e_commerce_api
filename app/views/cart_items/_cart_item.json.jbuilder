json.extract! cart_item, :id, :quantity, :created_at, :updated_at
json.url cart_cart_items_url(cart_item, format: :json)
json.product do
  json.partial! "products/product", product: cart_item.product
end
