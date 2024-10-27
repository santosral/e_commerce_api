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

RSpec.describe "/orders", type: :request do
  let(:cart) { create(:cart, :with_cart_items) }
  let(:order) { create(:order, :with_order_items) }

  # This should return the minimal set of attributes required to create a valid
  # Order. As you add validations to Order, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { cart_id: cart.id.to_s }
  }

  let(:invalid_attributes) {
    { cart_id: '11111111' }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # OrdersController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    { 'Accept' => 'application/json' }
  }

  describe "GET /index" do
    it "returns a list of orders" do
      get orders_url, headers: valid_headers, as: :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('application/json')
      expect(response).to match_response_schema('orders')
    end
  end

  describe "GET /orders/:id" do
    it "returns the order details" do
      get order_url(order), headers: valid_headers, as: :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(json_response["total_price"]).to eq(order.total_price.to_s)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Order" do
        expect {
          post orders_url,
               params: valid_attributes, headers: valid_headers, as: :json
        }.to change(Order, :count).by(1)
      end

      it "renders a JSON response with the new order" do
        post orders_url,
             params: valid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response).to match_response_schema('order')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Order" do
        expect {
          post orders_url,
               params: { order: invalid_attributes }, as: :json
        }.to change(Order, :count).by(0)
      end

      it "renders a JSON response with errors for the new order" do
        post orders_url,
             params: invalid_attributes, headers: valid_headers, as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response).to include("error")
      end
    end
  end
end
