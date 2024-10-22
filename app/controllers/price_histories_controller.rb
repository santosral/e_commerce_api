class PriceHistoriesController < ApplicationController
  before_action :set_price_history, only: %i[ show update destroy ]

  # GET /price_histories
  # GET /price_histories.json
  def index
    @price_histories = PriceHistory.all
  end

  # GET /price_histories/1
  # GET /price_histories/1.json
  def show
  end

  # POST /price_histories
  # POST /price_histories.json
  def create
    @price_history = PriceHistory.new(price_history_params)

    if @price_history.save
      render :show, status: :created, location: @price_history
    else
      render json: @price_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /price_histories/1
  # PATCH/PUT /price_histories/1.json
  def update
    if @price_history.update(price_history_params)
      render :show, status: :ok, location: @price_history
    else
      render json: @price_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /price_histories/1
  # DELETE /price_histories/1.json
  def destroy
    @price_history.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_price_history
      @price_history = PriceHistory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def price_history_params
      params.require(:price_history).permit(:product_id, :amount, :effective_date)
    end
end
