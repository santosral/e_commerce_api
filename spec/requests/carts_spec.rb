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

RSpec.describe "/carts", type: :request do
  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # CartsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    { 'Accept' => 'application/json' }
  }

  let(:cart) { create(:cart) }

  describe "POST /carts" do
    it "creates a new Cart" do
      expect {
        post carts_url, headers: valid_headers, as: :json
      }.to change(Cart, :count).by(1)
    end

    it "renders a JSON response with the new cart" do
      post carts_url, headers: valid_headers, as: :json
      expect(response).to have_http_status(:created)
      expect(response.content_type).to match(a_string_including("application/json"))

      expect(response).to match_response_schema('cart')
    end
  end

  describe "GET /carts/:id" do
    context "when the cart exists" do
      it "returns the cart" do
        get cart_url(cart), headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response['id']).to eq(cart.id.to_s)
        expect(json_response['total_price']).to eq(cart.total_price.formatted_amount)
        expect(response).to match_response_schema('cart')
      end
    end

    context "when the cart does not exist" do
      it "returns a not found status" do
        get cart_url(id: 'non-existent-id'), headers: valid_headers, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(json_response).to include("error")
      end
    end
  end
end
