module Prices
  class DemandRule < AdjustmentRule
    include Mongoid::Document
    include Mongoid::Timestamps

    field :add_to_cart_threshold, type: Integer
    field :order_threshold, type: Integer
    field :percentage, type: Float
  end
end
