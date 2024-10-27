json.extract! order_item, :id, :quantity, :created_at, :updated_at
json.url order_order_items_url(order_item, format: :json)
json.product do
  json.partial! "products/product", product: order_item.product
end
