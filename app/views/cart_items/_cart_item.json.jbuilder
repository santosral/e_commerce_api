product = cart_item.product

json.extract! cart_item, :id, :quantity, :created_at, :updated_at
json.url cart_cart_items_url(cart_item, format: :json)
json.product do
  json.extract! product, :id, :name, :quantity
  json.url product_url(product, format: :json)
  json.price do
    price = product.current_price&.amount || product.base_price
    json.id nil
    json.amount price
  end
end
