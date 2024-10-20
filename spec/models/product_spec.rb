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
    it { is_expected.to have_field(:default_price).of_type(Float) }
    it { is_expected.to have_field(:quantity).of_type(Integer) }
  end

  describe 'validations' do
    context 'when name is unique in different categories' do
      let(:another_category) { create(:category) }
      let(:valid_product) { build(:product, name: "Gadget", category: another_category) }

      before do
        create(:product, name: "Gadget", category: category)
      end

      it 'is valid' do
        expect(valid_product).to be_valid
      end
    end

    context 'when name already exist within the same category' do
      let(:duplicate_product) { build(:product, name: "Gadget", category: category) }

      before { create(:product, name: "Gadget", category: category) }

      it 'is not valid' do
        expect(duplicate_product).not_to be_valid
        expect(duplicate_product.errors[:name]).to include("already exists in the selected category")
      end
    end

    it { is_expected.to validate_presence_of(:name) }
  end

  pending '#current_price' do
    it 'returns the most recent price' do
      product = create(:product, category: category)
      price1 = product.prices.create(amount: 89.99, effective_date: 1.day.ago)
      price2 = product.prices.create(amount: 79.99, effective_date: Time.current)

      expect(product.current_price).to eq(price2)
    end

    it 'returns nil if there are no prices' do
      product = create(:product, category: category)

      expect(product.current_price).to be_nil
    end
  end
end
