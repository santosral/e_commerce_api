module Prices
  class AdjustmentRulesController < ApplicationController
    before_action :set_adjustment_rule, only: %i[ show update destroy ]

    # GET /prices/adjustment_rules
    # GET /prices/adjustment_rules.json
    def index
      @adjustment_rules = Prices::AdjustmentRule.all
    end

    # GET /prices/adjustment_rules/1
    # GET /prices/adjustment_rules/1.json
    def show
    end

    # POST /prices/adjustment_rules
    # POST /prices/adjustment_rules.json
    def create
      @adjustment_rule = Prices::AdjustmentRule.new(adjustment_rule_params)

      if @adjustment_rule.save
        render :show, status: :created, location: @adjustment_rule
      else
        render json: @adjustment_rule.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /prices/adjustment_rules/1
    # PATCH/PUT /prices/adjustment_rules/1.json
    def update
      if @adjustment_rule.update(adjustment_rule_params)
        render :show, status: :created, location: @adjustment_rule
      else
        render json: @adjustment_rule.errors, status: :unprocessable_entity
      end
    end

    # DELETE /prices/adjustment_rules/1
    # DELETE /prices/adjustment_rules/1.json
    def destroy
      @adjustment_rule.destroy!
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_adjustment_rule
        @adjustment_rule = Prices::AdjustmentRule.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def adjustment_rule_params
        params.require(:price_adjustment_rule).permit(:name, :strategy_type, :factor, :time_frame, :threshold, :competitor_rule, product_ids: [])
      end
  end
end
