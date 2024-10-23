json.product do
  json.extract! product, :id, :name, :quantity
  json.url product_url(product, format: :json)
  json.price do
    price = product.current_price&.amount || product.base_price
    json.id nil
    json.amount price
  end
end
