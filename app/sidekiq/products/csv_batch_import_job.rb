module Products
  class CsvBatchImportJob
    include Sidekiq::Job

    def perform(batch_products, import_status_id)
      require "bson"

      import_job = Products::ImportJob.find(import_status_id)
      Rails.logger.info "Starting CSV import for batch with ID: #{import_status_id}"

      begin
        transformed_products = batch_products.map do |product|
          {
            name: product["name"],
            category_id: BSON::ObjectId.from_string(product["category_id"]),
            default_price: product["default_price"].to_f,
            quantity: product["qty"].to_i
          }
        end

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
  end
end
