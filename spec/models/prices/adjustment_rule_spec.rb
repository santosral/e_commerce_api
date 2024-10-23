require 'rails_helper'

RSpec.describe Prices::AdjustmentRule, type: :model do
  it { is_expected.to be_mongoid_document }
  it { is_expected.to have_timestamps }

  describe 'fields' do
    it { is_expected.to have_field(:name).of_type(String) }
    it { is_expected.to have_field(:add_to_cart_threshold).of_type(Integer) }
    it { is_expected.to have_field(:order_threshold).of_type(Integer) }
    it { is_expected.to have_field(:factor).of_type(Float) }
    it { is_expected.to have_field(:time_frame).of_type(String) }
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:product) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(name: 1, products: 1).with_options(unique: true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:products) }
    it { is_expected.to validate_numericality_of(:add_to_cart_threshold).greater_than_or_equal_to(0).to_allow(only_integer: true) }
    it { is_expected.to validate_numericality_of(:order_threshold).greater_than_or_equal_to(0).to_allow(only_integer: true) }
    it { is_expected.to validate_numericality_of(:factor).greater_than_or_equal_to(0.0) }
    it { is_expected.to validate_inclusion_of(:time_frame).to_allow(Prices::AdjustmentRule::TIME_FRAMES) }
  end
end
