require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:category) { create(:category) }

  it { is_expected.to be_mongoid_document }
  it { is_expected.to have_timestamps }

  describe 'indexes' do
    it { is_expected.to have_index_for(name: 1, category_id: 1).with_options(unique: true) }
  end

  describe 'fields' do
    it { is_expected.to have_field(:name).of_type(String) }
    it { is_expected.to have_field(:default_price).of_type(BigDecimal).with_default_value_of(0) }
    it { is_expected.to have_field(:quantity).of_type(Integer).with_default_value_of(0) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:category_id) }
    it { is_expected.to validate_numericality_of(:default_price).greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:quantity).greater_than_or_equal_to(0) }
  end
end
