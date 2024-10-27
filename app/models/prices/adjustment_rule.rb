module Prices
  class AdjustmentRule
    include Mongoid::Document
    include Mongoid::Timestamps

    STRATEGY_TYPES = [ "cart_demand", "order_demand", "inventory", "competitor" ].freeze
    COMPETITOR_PRICING_RULES = [ "match", "undercut" ]

    field :name, type: String
    field :strategy_type, type: String
    field :factor, type: Float
    field :time_frame, type: String
    field :threshold, type: Integer, default: 0
    field :competitor_rule, type: String, default: nil

    index({ name: 1, products: 1 }, { unique: true })
    index({ strategy_type: 1, products: 1 }, { unique: true })

    has_and_belongs_to_many :product

    validates :name, presence: true
    validates :strategy_type, inclusion: { in: STRATEGY_TYPES, message: "must be one of #{STRATEGY_TYPES.join(', ')}" }
    validates :strategy_type, uniqueness: { scope: :products, message: "must be unique per product" }
    validates :factor, numericality: { greater_than_or_equal_to: 0.0, message: "must be a positive number or zero" }
    validates :time_frame, inclusion: { in: Metric::TIME_FRAMES, message: "must be either #{Metric::TIME_FRAMES.join(', ')}" }
    validates :competitor_rule, inclusion: { in: COMPETITOR_PRICING_RULES, message: "must be either #{COMPETITOR_PRICING_RULES.join(', ')}" }, if: -> { strategy_type == "competitor" }

    def can_apply_adjustment?(current_period)
      rule_period = Time.now.utc.strftime(Metric::TIME_FRAME_FORMATS[time_frame])

      rule_period == current_period
    end
  end
end
