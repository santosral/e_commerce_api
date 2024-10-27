require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { build(:order) }

  it 'is a Mongoid document' do
    expect(order).to be_mongoid_document
  end
  it 'has timestamps' do
    expect(order).to have_timestamps
  end

  describe 'fields' do
    it 'has a total_price field of type BigDecimal' do
      expect(order).to have_field(:total_price).of_type(BigDecimal).with_default_value_of(0.0)
    end
  end

  describe 'associations' do
    it 'has many order items' do
      expect(order).to have_many(:order_items)
    end
  end

  describe '.create_from_cart' do
    let!(:cart) { create(:cart) }
    let!(:product) { create(:product, base_price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
    let(:order_params) { { cart_id: cart.id.to_s } }

    context 'when cart has items' do
      it 'creates an order and order items' do
        order = Order.create_from_cart(order_params)

        expect(order).to be_persisted
        expect(order.order_items.count).to eq(1)
        expect(order.total_price).to eq(20.0)
      end

      it 'reduces product quantity after creating an order' do
        initial_quantity = product.quantity

        Order.create_from_cart(order_params)

        product.reload
        expect(product.quantity).to eq(initial_quantity - 2)
      end

      it 'destroys cart items after creating an order' do
        Order.create_from_cart(order_params)

        expect(cart.cart_items.count).to eq(0)
      end
    end

    context 'when cart has no items' do
      let(:empty_cart) { create(:cart) }
      let(:order_params) { { cart_id: empty_cart.id.to_s } }

      it 'adds an error and does not create an order' do
        order = Order.create_from_cart(order_params)

        expect(order.errors[:cart]).to include("No Cart Items to process")
        expect(order).not_to be_persisted
      end
    end

    context 'when order item is invalid' do
      before do
        allow_any_instance_of(OrderItem).to receive(:valid?).and_return(false)
      end

      it 'does not create an order and logs an error' do
        order = Order.create_from_cart(order_params)

        expect(order.errors[:order_items]).to be_present
        expect(order).not_to be_persisted
      end
    end
  end

  describe '#update_total_price' do
    let(:product) { create(:product, base_price: 15.0) }
    let(:order) { create(:order) }

    before do
      order.order_items << create(:order_item, order: order, product: product, quantity: 3)
      order.update_total_price
    end

    it 'calculates total price based on order items' do
      expect(order.total_price).to eq(45.0)
    end

    it 'sets total price to zero if there are no order items' do
      order.order_items.destroy_all
      order.update_total_price

      expect(order.total_price).to eq(0.0)
    end
  end
end
