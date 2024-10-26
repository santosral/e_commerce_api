require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart_item) { build(:cart_item, :with_product) }

  it 'is a Mongoid document' do
    expect(cart_item).to be_mongoid_document
  end

  it 'has timestamps' do
    expect(cart_item).to have_timestamps
  end

  describe 'fields' do
    it 'has a quantity field of type Integer' do
      expect(cart_item).to have_field(:quantity).of_type(Integer).with_default_value_of(1)
    end

    it 'has a captured_price_id field of type Bson::ObjectId' do
      expect(cart_item).to have_field(:captured_price_id).of_type(BSON::ObjectId)
    end
  end

  describe 'indexes' do
    it 'has an index on cart_id' do
      expect(cart_item).to have_index_for(cart_id: 1)
    end

    it 'has a unique index on product_id and cart_id' do
      expect(cart_item).to have_index_for(product_id: 1, cart_id: 1).with_options(unique: true)
    end
  end

  describe 'associations' do
    it 'belongs to a cart' do
      expect(cart_item).to belong_to(:cart)
    end

    it 'belongs to a product' do
      expect(cart_item).to belong_to(:product)
    end
  end

  describe 'validations' do
    it 'validates presence of product' do
      expect(cart_item).to validate_presence_of(:product)
    end

    it 'validates presence of cart' do
      expect(cart_item).to validate_presence_of(:cart)
    end

    it 'validates presence of quantity' do
      expect(cart_item).to validate_presence_of(:quantity)
    end

    it 'validates that quantity is greater than 0 and is an integer' do
      expect(cart_item).to validate_numericality_of(:quantity).greater_than(0).to_allow(only_integer: true)
    end

    context 'when creating a cart item' do
      it 'validates uniqueness of product_id scoped to cart_id' do
        expect(cart_item).to validate_uniqueness_of(:product_id).scoped_to(:cart_id).on(:create)
      end

      it 'validates captured price matches current product price' do
        cart_item.captured_price_id = nil
        expect(cart_item).to be_valid
      end

      it 'validates quantity does not exceed product stock' do
        cart_item.product.update(quantity: 5)
        cart_item.quantity = 5
        expect(cart_item).to be_valid
      end
    end

    context 'when not creating a cart item' do
      it 'does not validate uniqueness of product_id scoped to cart_id' do
        expect(cart_item).not_to validate_uniqueness_of(:product_id).scoped_to(:cart_id).on(:update)
      end

      it 'does not validate captured price with current product price' do
        cart_item.product.price_adjustments << build(:price)
        cart_item.captured_price_id = nil
        expect(cart_item.valid?(:update)).to be true
      end

      it 'does not validate quantity with product stock' do
        cart_item.product.update(quantity: 5)
        cart_item.quantity = 15
        expect(cart_item.valid?(:update)).to be true
      end
    end
  end

  describe '#remove_from_cart' do
    let(:cart) { create(:cart) }
    let(:cart_item) { create(:cart_item, :with_product, cart: cart) }

    it 'removes the cart item and updates the cart total' do
      expect { cart_item.remove_from_cart }.to change { cart_item.cart.cart_items.count }.by(-1)
      expect { cart_item.remove_from_cart }.to change { cart_item.cart.total_price }.to(0.0)
    end

    it 'logs the removal of the product' do
      allow(Rails.logger).to receive(:info)
      cart_item.remove_from_cart
      expect(Rails.logger).to have_received(:info).with("Removed product #{cart_item.product.id} from cart #{cart.id}")
    end

    it 'handles transaction failures gracefully' do
      allow(Rails.logger).to receive(:error)
      allow(cart_item).to receive(:destroy!).and_raise(StandardError.new("Something went wrong"))
      expect { cart_item.remove_from_cart }.not_to change { cart.cart_items.count }
      expect(Rails.logger).to have_received(:error).with("Failed to remove product #{cart_item.product.id} from cart #{cart.id}: Something went wrong")
    end
  end

  describe '#update_cart' do
    it 'updates the cart item and the cart total' do
      cart_item.quantity = 5
      expect(cart_item.update_cart(quantity: 5)).to be true
      expect(cart_item.quantity).to eq(5)
      expect(cart_item.cart.total_price).to eq(5 * cart_item.product.current_price.amount)
    end

    it 'returns false when the update is invalid' do
      cart_item.quantity = 0
      expect(cart_item.update_cart(quantity: 0)).to be false
      expect(cart_item.errors.messages).to be_present
    end

    it 'logs the update of the product' do
      allow(Rails.logger).to receive(:info)
      cart_item.update_cart(quantity: 5)
      expect(Rails.logger).to have_received(:info).with("Updated product #{cart_item.product.id} in cart #{cart_item.cart.id}.")
    end

    it 'handles transaction failures gracefully' do
      allow(Rails.logger).to receive(:info)
      allow(cart_item).to receive(:save!).and_raise(Mongoid::Errors::Validations.new(cart_item))
      expect(cart_item.update_cart(quantity: 5)).to be false
      expect(Rails.logger).to have_received(:info).with("Failed to update product #{cart_item.product.id} in cart #{cart_item.cart.id}: #{cart_item.errors.messages}")
    end
  end
end
