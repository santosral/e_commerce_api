class CartItemsController < ApplicationController
  before_action :set_cart, only: %i[ index create ]
  before_action :set_cart_item, only: %i[ show update destroy ]

  # GET /cart/:cart_id/cart_items
  # GET /cart/:cart_id/cart_items.json
  def index
    @cart_items = @cart.cart_items
  end

  # GET /cart_items/1
  # GET /cart_items/1.json
  def show
  end

  # POST /cart/:cart_id/cart_items
  # POST /cart/:cart_id/cart_items.json
  def create
    @cart_item = @cart.cart_items.build(cart_item_params)

    if @cart_item.save
      render :show, status: :created
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cart_items/1
  # PATCH/PUT /cart_items/1.json
  def update
    if @cart_item.update(cart_item_params)
      render :show, status: :ok, location: @cart_item
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cart_items/1
  # DELETE /cart_items/1.json
  def destroy
    if @cart_item.destroy
      head :no_content
    else
      render json: { error: "Unable to delete cart item" }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart
      @cart = Cart.find(params[:cart_id])
    end

    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cart_item_params
      params.require(:cart_item).permit(:product_id, :quantity, :captured_price_id)
    end
end
