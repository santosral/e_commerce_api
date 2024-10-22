module Products
  class CsvBatchImportJob
    include Sidekiq::Job

    def perform(batch_products, import_status_id)
      require "bson"

      import_job = Products::ImportJob.find(import_status_id)
      Rails.logger.info "Starting CSV import for batch with ID: #{import_status_id}"

      begin
        transformed_products = transformed_products(batch_products)
        service = Products::CsvImportService.new(transformed_products)
        result = service.call

        if result[:success]
          import_job.update!(status: "success")
          Rails.logger.info result.inspect
        else
          import_job.update!(status: "error")
          Rails.logger.error result.inspect
        end
      rescue StandardError => e
        import_job.update!(status: "error")
        Rails.logger.error "Failed to import batch for import status ID: #{import_status_id}. Error: #{e.message}"
      end
    end

    private

    def transformed_products(batch_products)
      batch_products.map do |product|
        {
          name: product["name"],
          category_id: BSON::ObjectId.from_string(product["category_id"]),
          quantity: product["quantity"].to_i,
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
          trend_tracker: {
            _id: BSON::ObjectId.new,
            add_to_cart_count: 0,
            order_count: 0
          },
          prices: [
            {
              _id: BSON::ObjectId.from_string(product["prices"][0]["_id"]),
              amount: BigDecimal(product["prices"][0]["amount"]),
              pricing_strategy: product["prices"][0]["pricing_strategy"],
              valid_from: product["prices"][0]["valid_from"],
              created_at: product["prices"][0]["created_at"],
              updated_at: product["prices"][0]["updated_at"]
            }
          ]
        }
      end
    end
  end
end
