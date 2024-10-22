module Prices
  class AdjustmentRule
    include Mongoid::Document
    include Mongoid::Timestamps

    TYPES = [ "increase", "decrease" ]

    field :adjustment_type, type: String
    field :percentage, type: Float

    has_and_belongs_to_many :products
  end
end
