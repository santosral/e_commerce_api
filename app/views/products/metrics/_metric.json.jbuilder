json.extract! metric, :id, :time_frame, :period
json.url product_metrics_url(metric, format: :json)
json.metrics metric.metrics
