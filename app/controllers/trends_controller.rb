class TrendsController < ApplicationController
  before_action :set_product

  # GET /products/:product_id/trends
  # GET /products/:product_id/trends.json
  def index
    @trends = @product.trends
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:product_id])
    end
end
