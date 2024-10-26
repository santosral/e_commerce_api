class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: %i[ show update destroy ]

  # GET /cart/:cart_id/cart_items
  # GET /cart/:cart_id/cart_items.json
  def index
    @cart_items = @cart.cart_items
  end

  # GET /cart/:cart_id/cart_items/1
  # GET /cart/:cart_id/cart_items/1.json
  def show
  end

  # POST /cart/:cart_id/cart_items
  # POST /cart/:cart_id/cart_items.json
  def create
    @cart_item = @cart.add_cart_item(cart_item_params)

    if @cart_item
      render :show, status: :created
    else
      render json: { errors: @cart.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cart/:cart_id/cart_items/1
  # PATCH/PUT /cart/:cart_id/cart_items/1.json
  def update
    if @cart_item.update_cart(cart_item_params)
      render :show, status: :ok
    else
      render json: { errors: @cart.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /cart/:cart_id/cart_items/1
  # DELETE /cart/:cart_id/cart_items/1.json
  def destroy
    if @cart_item.remove_from_cart
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
      if action_name == "create"
        create_cart_item_params
      else
        update_cart_item_params
      end
    end

    def create_cart_item_params
      params.require(:cart_item).permit(:product_id, :quantity, :captured_price_id)
    end

    def update_cart_item_params
      params.require(:cart_item).permit(:quantity)
    end
end
