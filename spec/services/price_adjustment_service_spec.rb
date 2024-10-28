require 'rails_helper'

RSpec.describe PriceAdjustmentService do
  let(:product) { create(:product) }
  let(:time_frame) { "daily" }
  let(:strategy_type) { "cart_demand" }
  let(:service) { described_class.new(product, time_frame: time_frame, strategy_type: strategy_type) }

  describe '#call' do
    context 'when no adjustment rule exists' do
      it 'returns a failure result' do
        result = service.call
        expect(result.success?).to be false
        expect(result.message).to eq("No demand adjustment rule found for product #{product.id}")
      end
    end

    context 'when a rule exists' do
      let!(:rule) { create(:prices_adjustment_rule, products: [ product ], time_frame: time_frame, strategy_type: strategy_type, factor: 1.2, threshold: 5) }
      let!(:trend) { create(:trend, product: product, cart_additions_count: 6, orders_count: 2) }

      it 'applies the price adjustment successfully' do
        result = service.call
        expect(result.success?).to be true
        expect(result.message).to eq("Price adjustment applied successfully")
        expect(result.price_adjustment).to be_present
        expect(result.price_adjustment.amount).to eq(product.base_price * rule.factor)
      end

      context 'when the trend does not fulfill the rule' do
        before do
          allow(Trend).to receive(:aggregate_by_timeframe).and_return(total_cart_additions: 0, total_orders: 0)
        end

        it 'returns a failure result' do
          result = service.call
          expect(result.success?).to be false
          expect(result.message).to eq("cart_demand does not fulfill the rule")
        end
      end

      context 'when price adjustment already exists' do
        before do
          create(:price, adjustment_rule_time_frame: time_frame, pricing_strategy: strategy_type, item: product)
        end

        it 'returns a failure result' do
          result = service.call
          expect(result.success?).to be false
          expect(result.message).to eq("Price #{rule.name} #{strategy_type} already applied")
        end
      end

      context 'when calculated amount is nil' do
        before do
          allow(service).to receive(:calculate_adjusted_price).and_return(nil)
        end

        it 'returns a failure result' do
          result = service.call
          expect(result.success?).to be false
          expect(result.message).to eq("Calculated price is null #{product.id}")
        end
      end
    end
  end
end
