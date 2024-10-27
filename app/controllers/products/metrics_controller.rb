module Products
  class MetricsController < ApplicationController
    before_action :set_product

    # GET products/:product_id/metrics
    # GET products/:product_id/metrics.json
    def index
      @metrics = @product.metrics
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_product
        @product = Product.find(params[:product_id])
      end
  end
end
