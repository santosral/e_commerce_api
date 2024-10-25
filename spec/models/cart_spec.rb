require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:cart) { build(:cart) }

  it 'is a Mongoid document' do
    expect(cart).to be_mongoid_document
  end

  it 'has timestamps' do
    expect(cart).to have_timestamps
  end

  describe 'fields' do
    it 'has a total_price field of type BigDecimal' do
      expect(cart).to have_field(:total_price).of_type(BigDecimal)
    end
  end

  describe '#update_total_price' do
    context 'when cart is empty' do
      before { cart.update_total_price }

      it 'sets total_price to 0.0' do
        expect(cart.total_price).to eq(0.0)
      end
    end

    context 'when cart has items without captured price' do
     let(:cart) { create(:cart, :with_cart_items, cart_items_count: 3, product_base_price: 100.00) }

     before { cart.update_total_price }

      it 'calculates total price based on base price' do
        expect(cart.total_price.to_f).to eq(300.0)
      end
    end

    context 'when cart has items with captured price' do
      let(:cart) { create(:cart, :with_price_adjusted_cart_items, cart_items_count: 1, product_base_price: 100.00, price_adjustment_amount: 150.00) }

      before { cart.update_total_price }

       it 'calculates total price based on base price' do
         expect(cart.total_price.to_f).to eq(150.00)
       end
     end

     context 'when cart has mixed items' do
      let(:cart) { create(:cart, :with_cart_items, cart_items_count: 1, product_base_price: 100.00) }

      before do
        create(:cart_item, :with_price_adjusted_product, cart: cart, product_base_price: 100.00, price_adjustment_amount: 150.00)
        cart.update_total_price
      end

      it 'calculates total price correctly' do
        expect(cart.total_price.to_f).to eq(100.0 + 150.0)
      end
    end
  end
end
