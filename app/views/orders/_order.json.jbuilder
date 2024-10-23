json.extract! order, :id, :total_price, :created_at, :updated_at
json.url order_url(order, format: :json)
json.order_items order.order_items do |item|
  json.partial! "order_items/order_item", order_item: item
end
