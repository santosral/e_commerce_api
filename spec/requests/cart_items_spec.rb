require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/cart_items", type: :request do
  let(:cart) { create(:cart) }
  let(:cart_item_product) { create(:product) }
  let(:cart_item) { create(:cart_item, cart: cart, product: cart_item_product) }
  let(:new_product) { create(:product) }

  # This should return the minimal set of attributes required to create a valid
  # CartItem. As you add validations to CartItem, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { cart_item: { product_id: new_product.id.to_s, quantity: 1  } }
  }

  let(:invalid_attributes) {
    { cart_item: { quantity: nil } }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # CartItemsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    { 'Accept' => 'application/json' }
  }

  describe "GET /carts/:cart_id/cart_items" do
    it "returns a list of cart items" do
      get cart_cart_items_url(cart_item.cart), headers: valid_headers, as: :json

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('cart_items')
    end
  end

  describe "GET /carts/:cart_id/cart_items/:id" do
    it "returns a specific cart item" do
      get cart_cart_item_url(cart_item.cart, cart_item), headers: valid_headers, as: :json

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema("cart_item")
    end
  end

  describe "POST /carts/:cart_id/cart_items" do
    context "with valid parameters" do
      it "creates a new cart item" do
        expect {
          post cart_cart_items_url(cart), params: valid_attributes, headers: valid_headers, as: :json
        }.to change(CartItem, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response).to match_response_schema("cart_item")
      end
    end

    context "with invalid parameters" do
      it "does not create a cart item" do
        post cart_cart_items_url(cart), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("errors")
      end
    end
  end

  describe "PATCH /carts/:cart_id/cart_items/:id" do
    context "with valid parameters" do
      before do
        valid_attributes[:cart_item][:quantity] = 15
      end

      it "updates the requested cart item" do
        valid_attributes[:cart_item][:quantity] = 15

        patch cart_cart_item_url(cart, cart_item), params: valid_attributes, headers: valid_headers, as: :json

        cart_item.reload
        expect(cart_item.quantity).to eq(15)
        expect(response).to match_response_schema("cart_item")
      end

      it "renders a JSON response with the cart_item" do
        patch cart_cart_item_url(cart, cart_item), params: valid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response).to match_response_schema("cart_item")
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the cart_item" do
        patch cart_cart_item_url(cart, cart_item), params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response.body).to include("errors")
      end
    end
  end
end
