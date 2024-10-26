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

  describe '#add_cart_item' do
    let(:product) { create(:product) }
    let(:cart) { create(:cart) }
    let(:cart_item_params) { { product_id: product.id.to_s, quantity: 1 } }

    it 'saves the cart item and updates the cart total' do
      expect(cart.add_cart_item(cart_item_params)).to be_a(CartItem)
      expect(cart.total_price).to eq(cart_item_params[:quantity] * product.current_price.amount)
    end

    context 'when cart item is invalid' do
      let(:cart_item_params) { { product_id: nil, quantity: 1 } }

      it 'returns false' do
        expect(cart.add_cart_item(cart_item_params)).to be false
        expect(cart.errors.messages).to be_present
      end
    end

    context 'when same product was added to the cart' do
      let(:product) { create(:product) }
      let(:cart_item) { create(:cart_item, product: product) }
      let(:cart_item_params) { { product_id: product.id.to_s, quantity: 1 } }

      it 'do not allow adding the same product to the cart' do
        expect(cart_item.cart.add_cart_item(cart_item_params)).to be false
        expect(cart_item.cart.errors.messages).to include(cart_item: [ { product_id: [ "has already been added to this cart" ] } ])
      end
    end

    it 'logs the addition of the product' do
      allow(Rails.logger).to receive(:info)
      cart.add_cart_item(cart_item_params)
      expect(Rails.logger).to have_received(:info).with("Added product #{product.id} to cart #{cart.id}")
    end

    it 'handles transaction failures gracefully' do
      allow(Rails.logger).to receive(:info)
      allow(cart).to receive(:save!).and_raise(Mongoid::Errors::Validations.new(cart))

      expect(cart.add_cart_item(cart_item_params)).to be false
      expect(Rails.logger).to have_received(:info).with("Validation errors: #{cart.errors.messages}")
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
