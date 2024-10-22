require "rails_helper"

RSpec.describe PriceHistoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/price_histories").to route_to("price_histories#index")
    end

    it "routes to #show" do
      expect(get: "/price_histories/1").to route_to("price_histories#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/price_histories").to route_to("price_histories#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/price_histories/1").to route_to("price_histories#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/price_histories/1").to route_to("price_histories#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/price_histories/1").to route_to("price_histories#destroy", id: "1")
    end
  end
end
