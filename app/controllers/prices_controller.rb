class PricesController < ApplicationController
  before_action :set_product

  # GET products/:product_id/prices
  # GET products/:product_id/prices.json
  def index
    @prices = @product.price_adjustments
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:product_id])
    end
end
