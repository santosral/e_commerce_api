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

    has_and_belongs_to_many :products

    validates :name, presence: true
    validates :strategy_type, inclusion: { in: STRATEGY_TYPES, message: "must be one of #{STRATEGY_TYPES.join(', ')}" }
    validates :strategy_type, uniqueness: { scope: :products, message: "must be unique per product" }
    validates :factor, numericality: { greater_than_or_equal_to: 0.0, message: "must be a positive number or zero" }
    validates :time_frame, inclusion: { in: TimeFrame::TIME_FRAMES, message: "must be either #{TimeFrame::TIME_FRAMES.join(', ')}" }
    validates :time_frame, uniqueness: { scope: :strategy_type, message: "must be unique per product" }

    with_options if: -> { strategy_type == "competitor" } do
      validates :competitor_rule, inclusion: { in: COMPETITOR_PRICING_RULES, message: "must be either #{COMPETITOR_PRICING_RULES.join(', ')}" }
      validates :competitor_rule, uniqueness: { scope: :products, message: "must be unique per product" }

      after_create :queue_fetch_competitor_price
      after_destroy :destroy_fetch_competitor_price_job
    end

    private
      def queue_fetch_competitor_price
        cron_date = TimeFrame.generate_cron_expression(time_frame)

        Sidekiq::Cron::Job.create(
          name: id.to_s,
          namespace: "adjustment_rule",
          cron: cron_date,
          class: "Prices::FetchCompetitorPricesJob",
          args: { "id" => id.to_s }
        )
      end

      def destroy_fetch_competitor_price_job
        Sidekiq::Cron::Job.destroy(id.to_s)
      end
  end
end
