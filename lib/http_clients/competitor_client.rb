module HttpClients
  class CompetitorClient
    include HTTParty
    base_uri ENV["COMPETITOR_API_BASE_URI"]

    def self.fetch_prices
      api_key = ENV["COMPETITOR_API_KEY"]
      Rails.logger.info "Fetching competitor prices"

      response = get("/prices", query: { api_key: api_key })

      handle_response(response)
    rescue HTTParty::Error => e
      Rails.logger.error "HTTP request failed: #{e.message}"
    end

    private

    def self.handle_response(response)
      case response.code
      when 200
        Rails.logger.info "Successfully fetched competitor prices."
        response
      when 400
        Rails.logger.warn "Bad request: #{response.message}"
        nil
      when 404
        Rails.logger.warn "Competitor not found: #{response.message}"
        nil
      when 500
        Rails.logger.error "Server error: #{response.message}"
        nil
      else
        Rails.logger.error "Unexpected response: #{response.message}"
        nil
      end
    end
  end
end
