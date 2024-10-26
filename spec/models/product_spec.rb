require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { build(:product) }

  it 'is a Mongoid document' do
    expect(product).to be_mongoid_document
  end
  it 'has timestamps' do
    expect(product).to have_timestamps
  end

  describe 'fields' do
    it 'has a name field of type String' do
      expect(product).to have_field(:name).of_type(String)
    end

    it 'has a base_price field of type BigDecimal' do
      expect(product).to have_field(:base_price).of_type(BigDecimal)
    end

    it 'has a quantity field of type Integer with a default value of 0' do
      expect(product).to have_field(:quantity).of_type(Integer).with_default_value_of(0)
    end
  end

  describe 'indexes' do
    it 'has a unique index on name and category_id' do
      expect(product).to have_index_for(name: 1, category_id: 1).with_options(unique: true)
    end
  end

  describe 'associations' do
    it 'belongs to a category' do
      expect(product).to belong_to(:category)
    end

    it 'has many cart items' do
      expect(product).to have_many(:cart_items)
    end

    it 'has many order items' do
      expect(product).to have_many(:order_items)
    end

    it 'has many metrics' do
      expect(product).to have_many(:metrics)
    end

    it 'has and belongs to many price adjustment rules of type Prices::AdjustmentRule' do
      expect(product).to have_and_belong_to_many(:price_adjustment_rules).of_type(Prices::AdjustmentRule)
    end

    it 'embeds many price adjustments of type Price' do
      expect(product).to embed_many(:price_adjustments).of_type(Price)
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      expect(product).to validate_presence_of(:name)
    end

    it 'validates uniqueness of name scoped to category_id' do
      expect(product).to validate_uniqueness_of(:name).scoped_to(:category_id)
    end

    it 'is valid with base_price is greater than 0' do
      product.base_price = BigDecimal("100.00")
      expect(product).to be_valid
    end

    it 'is not valid with base_price equal to zero' do
      product.base_price = BigDecimal("0.00")
      expect(product).not_to be_valid
    end

    it 'is not valid with base_price less than zero' do
      product.base_price = BigDecimal("-1")
      expect(product).not_to be_valid
    end

    it 'validates that quantity is greater than or equal to 0 and is an integer' do
      expect(product).to validate_numericality_of(:quantity).greater_than_or_equal_to(0).to_allow(only_integer: true)
    end
  end

  describe '#current_price' do
    context 'when no price adjustments exist' do
      it 'returns the base price' do
        expect(product.current_price.amount).to eq(product.base_price)
      end
    end

    context 'when a valid adjustment exists' do
      let(:product) { create(:product, :with_price_adjustments, price_adjustments_count: 1, amount: BigDecimal("900.00")) }

      it 'returns the adjusted price' do
        expect(product.current_price.amount).to eq(BigDecimal("900.00"))
      end
    end

    context 'when multiple price adjustments exist' do
      let(:product) { create(:product) }

      before do
        older_adjustment = build(:price, amount: BigDecimal("800.00"), effective_date: 1.day.ago)
        newer_adjustment = build(:price, amount: BigDecimal("900.00"), effective_date: DateTime.now.utc)
        product.price_adjustments << older_adjustment
        product.price_adjustments << newer_adjustment
      end

      it 'returns the latest price adjustment' do
        expect(product.current_price.amount).to eq(BigDecimal("900.00"))
      end
    end
  end

  describe '#increase_cart_metrics' do
    let(:product) { create(:product) }

    before do
      product.increase_cart_metrics
    end

    it 'increments order_count for all time frames' do
      Metric::TIME_FRAME_FORMATS.keys.each do |time_frame|
        metric = product.metrics.find_by(time_frame: time_frame)
        expect(metric.metrics['add_to_cart_count']).to eq(1)
      end
    end
  end

  describe '#increase_order_metrics' do
    let(:product) { create(:product) }

    before do
      product.increase_order_metrics
    end

    it 'increments order_count for all time frames' do
      Metric::TIME_FRAME_FORMATS.keys.each do |time_frame|
        metric = product.metrics.find_by(time_frame: time_frame)
        expect(metric.metrics['order_count']).to eq(1)
      end
    end
  end

  describe '#apply_price_adjustment_rules_by_demand' do
    let(:product) do
      create(:product, :with_demand_adjustments, base_price: 100.00,
        period: Time.now.utc.strftime(Metric::TIME_FRAME_FORMATS['daily']))
    end

    before do
      Timecop.freeze(Time.now)
      product.apply_price_adjustment_rules_by_demand
    end

    after do
      Timecop.return
    end

    it 'applies price adjustment rules based on demand' do
      expect(product.price_adjustments.count).to eq(1)
      expect(product.price_adjustments.last.amount.to_i).to be > 100.00
    end

    context 'when no rules are present' do
      before { product.price_adjustment_rules.clear }

      it 'does not apply adjustment' do
        expect { product.apply_price_adjustment_rules_by_demand }.not_to change { product.price_adjustments.count }
      end
    end

    context 'when demand threshold is not met' do
      before { product.metrics.first.update(metrics: { add_to_cart_count: 4 }) }

      it 'does not apply adjustment' do
        expect { product.apply_price_adjustment_rules_by_demand }.not_to change { product.price_adjustments.count }
      end
    end

    context 'when no valid metrics exist' do
      before { product.metrics.destroy_all }

      it 'does not apply adjustment' do
        expect { product.apply_price_adjustment_rules_by_demand }.not_to change { product.price_adjustments.count }
      end
    end

    context 'when adjustment has already been applied' do
      before do
        product.metrics.first.update(metrics: { add_to_cart_count: 6 })
        product.apply_price_adjustment_rules_by_demand
      end

      it 'does not apply adjustment multiple times under the same conditions' do
        expect { product.apply_price_adjustment_rules_by_demand }.not_to change { product.price_adjustments.count }
      end
    end
  end

  describe '#reduce_quantity' do
    let(:product) { create(:product, quantity: 5) }
    it 'reduces the quantity correctly' do
      product.reduce_quantity(2)
      expect(product.quantity).to eq(3)
    end

    it 'raises an error when reducing more than available' do
      expect { product.reduce_quantity(6) }.to raise_error(Mongoid::Errors::Validations)
    end

    it 'does not raise an error when reducing to zero' do
      expect { product.reduce_quantity(5) }.not_to raise_error
      expect(product.quantity).to eq(0)
    end

    it 'does not allow quantity to go negative' do
      product.reduce_quantity(5)
      expect { product.reduce_quantity(1) }.to raise_error(Mongoid::Errors::Validations)
    end
  end
end