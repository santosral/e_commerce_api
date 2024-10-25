class CartsController < ApplicationController
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
end
