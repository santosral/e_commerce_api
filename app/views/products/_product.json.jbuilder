json.extract! product, :id, :name, :quantity, :created_at, :updated_at
json.url product_url(product, format: :json)

json.price product.prices do |price|
  json.partial! "prices/price", price: price
end
