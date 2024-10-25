json.extract! product, :id, :name, :quantity
json.url product_url(product, format: :json)
json.price do
  json.partial! "prices/price", price: product.current_price
end
