require 'rails_helper'

RSpec.describe Trend, type: :model do
  let(:product) { create(:product) }
  let(:trend) { build(:trend) }

  before do
    Timecop.freeze(Time.now)
  end

  after do
    Timecop.return
  end

  it 'is a Mongoid document' do
    expect(trend).to be_mongoid_document
  end
  it 'has timestamps' do
    expect(trend).to have_timestamps
  end

  describe 'associations' do
    it 'belongs to a product' do
      expect(trend).to belong_to(:product)
    end
  end
  describe '.aggregate_historical_data' do
    before do
      create(:trend, product: product, cart_additions_count: 5, orders_count: 3, recorded_at: 1.day.ago)
      create(:trend, product: product, cart_additions_count: 10, orders_count: 7, recorded_at: Time.zone.now)
      create(:trend, product: product, cart_additions_count: 2, orders_count: 1, recorded_at: 2.days.ago)
    end

    it 'aggregates cart additions and orders correctly for a date range' do
      result = Trend.aggregate_historical_data(product_id: product.id, start_date: 2.days.ago, end_date: Time.zone.now)
      expect(result[:total_cart_additions]).to eq(17)
      expect(result[:total_orders]).to eq(11)
    end

    it 'returns zero counts when no trends exist for the date range' do
      result = Trend.aggregate_historical_data(product_id: product.id, start_date: 4.days.ago, end_date: 3.days.ago)
      expect(result[:total_cart_additions]).to eq(0)
      expect(result[:total_orders]).to eq(0)
    end
  end

  describe '.increment_daily_trend' do
    context 'when trend does not exist for today' do
      it 'creates a new trend record and increments the cart additions count' do
        expect {
          Trend.increment_daily_trend(product: product, type: "cart_additions_count")
        }.to change { Trend.count }.by(1)

        trend = Trend.where(product: product, recorded_at: Time.now.beginning_of_day...Time.now.end_of_day).first
        expect(trend.cart_additions_count).to eq(1)
      end
    end

    context 'when trend already exists for today' do
      before do
        trend.update(cart_additions_count: 5, product: product)
      end

      it 'increments the existing trend cart additions count' do
        Trend.increment_daily_trend(product: product, type: "cart_additions_count")

        trend.reload
        expect(trend.cart_additions_count).to eq(6)
      end
    end

    context 'when incrementing orders count' do
      it 'increments the orders count' do
        Trend.increment_daily_trend(product: product, type: "orders_count")

        trend = Trend.where(product: product, recorded_at: Time.now.beginning_of_day...Time.now.end_of_day).first
        expect(trend.orders_count).to eq(1)
      end
    end

    context 'when an invalid type is provided' do
      it 'raises an ArgumentError' do
        expect {
          Trend.increment_daily_trend(product: product, type: "invalid_type")
        }.to raise_error(ArgumentError, "Invalid type: invalid_type")
      end
    end
  end
end
