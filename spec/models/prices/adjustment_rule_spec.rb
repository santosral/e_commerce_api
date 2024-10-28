require 'rails_helper'

RSpec.describe Prices::AdjustmentRule, type: :model do
  let(:product) { create(:product) }
  let(:adjustment_rule) { build(:prices_adjustment_rule, products: [ product ]) }

  it 'is a Mongoid document' do
    expect(adjustment_rule).to be_mongoid_document
  end
  it 'has timestamps' do
    expect(adjustment_rule).to have_timestamps
  end

  describe 'fields' do
    it 'has a name field of type String' do
      expect(adjustment_rule).to have_field(:name).of_type(String)
    end

    it 'has a threshold field of type Integer' do
      expect(adjustment_rule).to have_field(:threshold).of_type(Integer)
    end

    it 'has a factor field of type Float' do
      expect(adjustment_rule).to have_field(:factor).of_type(Float)
    end

    it 'has a time_frame field of type String' do
      expect(adjustment_rule).to have_field(:time_frame).of_type(String)
    end

    it 'has a strategy_type field of type String' do
      expect(adjustment_rule).to have_field(:strategy_type).of_type(String)
    end

    it 'has a competitor_rule field of type String with a default value of nil' do
      expect(adjustment_rule).to have_field(:competitor_rule).of_type(String).with_default_value_of(nil)
    end
  end

  describe 'associations' do
    it 'has a many-to-many relationship with products' do
      expect(adjustment_rule).to have_and_belong_to_many(:products)
    end
  end

  describe 'indexes' do
    it 'has a unique index on name and products' do
      expect(adjustment_rule).to have_index_for(name: 1, products: 1).with_options(unique: true)
    end

    it 'has a unique index on strategy_type and products' do
      expect(adjustment_rule).to have_index_for(strategy_type: 1, products: 1).with_options(unique: true)
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      expect(adjustment_rule).to validate_presence_of(:name)
    end

    it 'validates uniqueness of name scoped to product' do
      expect(adjustment_rule).to validate_uniqueness_of(:strategy_type).scoped_to(:products)
    end

    it 'validates uniqueness of strategy_type scoped to product' do
      expect(adjustment_rule).to validate_uniqueness_of(:strategy_type).scoped_to(:products)
    end

    it 'validates that factor is a number greater than or equal to 0.0' do
      expect(adjustment_rule).to validate_numericality_of(:factor).greater_than_or_equal_to(0.0)
    end

    it 'validates inclusion of time_frame in predefined options' do
      expect(adjustment_rule).to validate_inclusion_of(:time_frame).to_allow(TimeFrame::TIME_FRAMES)
    end

    it 'validates uniqueness of time_frame scoped to strategy type' do
      expect(adjustment_rule).to validate_uniqueness_of(:time_frame).scoped_to(:strategy_type)
    end

    it 'validates inclusion of strategy_type in predefined options' do
      expect(adjustment_rule).to validate_inclusion_of(:strategy_type).to_allow(Prices::AdjustmentRule::STRATEGY_TYPES)
    end

    context 'when strategy_type is "competitor"' do
      let(:adjustment_rule) { build(:prices_adjustment_rule, strategy_type: 'competitor') }

      it 'validates inclusion of competitor_rule in predefined competitor pricing rules' do
        expect(adjustment_rule).to validate_inclusion_of(:competitor_rule).to_allow(Prices::AdjustmentRule::COMPETITOR_PRICING_RULES)
      end

      it 'validates uniqueness of competitor_rule scoped to product' do
        expect(adjustment_rule).to validate_uniqueness_of(:competitor_rule).scoped_to(:products)
      end
    end
  end
end
