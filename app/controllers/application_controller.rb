class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

  private

  def not_found
    render json: { error: "Resource not found" }, status: :not_found
  end

  def handle_missing_parameter(exception)
    Rails.logger.error("Missing parameter: #{exception.message}")
    render json: { error: exception.message }, status: :bad_request
  end
end
