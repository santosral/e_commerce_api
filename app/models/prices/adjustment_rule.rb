module Prices
  class AdjustmentRule
    include Mongoid::Document
    include Mongoid::Timestamps

    STRATEGY_TYPES = [ "demand", "inventory", "competitor" ].freeze

    field :name, type: String
    field :strategy_type, type: String
    field :add_to_cart_threshold, type: Integer
    field :order_threshold, type: Integer
    field :factor, type: Float
    field :time_frame, type: String

    index({ name: 1, products: 1 }, { unique: true })
    index({ strategy_type: 1, products: 1 }, { unique: true })

    has_and_belongs_to_many :product

    validates :name, presence: true
    validates :name, uniqueness: { scope: :product, message: "must be unique per product" }
    validates :strategy_type, inclusion: { in: STRATEGY_TYPES, message: "must be one of #{STRATEGY_TYPES.join(', ')}" }
    validates :strategy_type, uniqueness: { scope: :products, message: "must be unique per product" }
    validates :add_to_cart_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :order_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :factor, numericality: { greater_than_or_equal_to: 0.0, message: "must be a positive number or zero" }
    validates :time_frame, inclusion: { in: Metric::TIME_FRAMES, message: "must be either #{Metric::TIME_FRAMES.join(', ')}" }

    def can_apply_adjustment?(current_period)
      rule_period = Time.now.utc.strftime(Metric::TIME_FRAME_FORMATS[time_frame])

      rule_period == current_period
    end
  end
end
