class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_error
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

  def handle_internal_error(exception)
    Rails.logger.error("Internal server error: #{exception.message}")
    render json: { error: "Internal server error" }, status: :internal_server_error
  end
end
