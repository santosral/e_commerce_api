class TrendTrackersController < ApplicationController
  before_action :set_trend_tracker, only: %i[ show update destroy ]

  # GET /trend_trackers
  # GET /trend_trackers.json
  def index
    @trend_trackers = TrendTracker.all
  end

  # GET /trend_trackers/1
  # GET /trend_trackers/1.json
  def show
  end

  # POST /trend_trackers
  # POST /trend_trackers.json
  def create
    @trend_tracker = TrendTracker.new(trend_tracker_params)

    if @trend_tracker.save
      render :show, status: :created, location: @trend_tracker
    else
      render json: @trend_tracker.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trend_trackers/1
  # PATCH/PUT /trend_trackers/1.json
  def update
    if @trend_tracker.update(trend_tracker_params)
      render :show, status: :ok, location: @trend_tracker
    else
      render json: @trend_tracker.errors, status: :unprocessable_entity
    end
  end

  # DELETE /trend_trackers/1
  # DELETE /trend_trackers/1.json
  def destroy
    @trend_tracker.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trend_tracker
      @trend_tracker = TrendTracker.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def trend_tracker_params
      params.require(:trend_tracker).permit(:product_id, :add_to_cart_count, :order_count)
    end
end
