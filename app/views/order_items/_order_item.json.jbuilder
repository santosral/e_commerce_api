json.extract! order_item, :id, :quantity, :created_at, :updated_at
# json.url order_order_item_url(order_item, format: :json)
json.product do
  json.partial! "products/product_adjusted_price", product: order_item.product
end
