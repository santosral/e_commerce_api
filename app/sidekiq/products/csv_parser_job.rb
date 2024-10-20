module Products
  class CsvParserJob
    include Sidekiq::Job

    BATCH_SIZE = 10

    def perform(file_path, import_status_id)
      Rails.logger.info "Started CsvParserJob for file: #{file_path}, ImportStatus ID: #{import_status_id}"
      import_job = Products::ImportJob.find(import_status_id)
      import_job.update!(status: "processing")
      service = Products::CsvParserService.new(file_path)
      batch_data = []
      batch_transformed_data = []

      result = service.call do |row, product_attributes, index|
        batch_data << row
        batch_transformed_data << product_attributes
        batch_transformed_data_size = batch_transformed_data.size

        if batch_transformed_data_size >= BATCH_SIZE
          Products::CsvBatchImportJob.perform_async(batch_transformed_data, import_status_id)
          Rails.logger.info "Queued batch import for ImportStatus ID: #{import_status_id} with #{batch_transformed_data_size} products."
          import_job.valid_rows += batch_data
          import_job.save!
          batch_data.clear
          batch_transformed_data.clear
        end
      end

      if result[:success]
        Rails.logger.info "CSV parsing succeeded: #{import_job.valid_rows.size} valid rows, #{service.invalid_rows.size} invalid rows."
        import_job.update!(status: "success", invalid_rows: service.invalid_rows.as_json)
      else
        Rails.logger.error "CSV parsing failed for file: #{file_path}."
        import_job.update!(status: "error")
      end
    rescue StandardError => e
      import_job.update!(status: "error") if import_job.present?
      Rails.logger.error("CsvParserJob failed for file: #{e}")
    ensure
      # Delete the tempfile
      Rails.logger.info "Deleting temporary file: #{file_path}"

      begin
        File.delete(file_path)
      rescue StandardError => e
        Rails.logger.error("Failed to delete temporary file: #{e}")
      end
    end
  end
end
