class Metric
  include Mongoid::Document
  include Mongoid::Timestamps

  TIME_FRAMES = [ "daily", "weekly", "monthly", "yearly" ].freeze
  TIME_FRAME_FORMATS = {
    "daily" => "%Y-%m-%d",
    "weekly" => "%Y-W%U",
    "monthly" => "%Y-%m",
    "yearly" => "%Y"
  }.freeze
  TYPES = [ "add_to_cart_count", "order_count", "competitor_price" ].freeze

  field :time_frame, type: String
  field :period, type: String
  field :metrics, type: Hash, default: {}

  belongs_to :product

  validates :time_frame, inclusion: { in: TIME_FRAMES, message: "must be either #{TIME_FRAMES.join(', ')}" }
  validates :period, presence: true
  validate :validate_metrics_keys

  def increment_metric(metric_name, increment_by = 1)
    self.metrics[metric_name] ||= 0
    self.metrics[metric_name] += increment_by
  end

  def get_metric(metric_name)
    metrics[metric_name] || 0
  end

  private
    def validate_metrics_keys
      metrics.each_key do |key|
        if TYPES.exclude?(key)
          errors.add(:metrics, "#{key} is not a valid metric key. Allowed keys are: #{TYPES.join(', ')}")
        end
      end
    end
end
