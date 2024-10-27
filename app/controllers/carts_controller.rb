class CartsController < ApplicationController
  before_action :set_cart, only: :show

  # GET /carts/1
  # GET /carts/1.json
  def show
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new

    if @cart.save
      render :show, status: :created, location: @cart
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = Cart.find(params[:id])
    end
end
