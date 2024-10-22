require "rails_helper"

RSpec.describe TrendTrackersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/trend_trackers").to route_to("trend_trackers#index")
    end

    it "routes to #show" do
      expect(get: "/trend_trackers/1").to route_to("trend_trackers#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/trend_trackers").to route_to("trend_trackers#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/trend_trackers/1").to route_to("trend_trackers#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/trend_trackers/1").to route_to("trend_trackers#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/trend_trackers/1").to route_to("trend_trackers#destroy", id: "1")
    end
  end
end
