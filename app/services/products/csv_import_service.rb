require "csv"

module Products
  class CsvImportService
    attr_accessor :rows

    def initialize(rows)
      @rows = rows
    end

    def call
      Rails.logger.info "Starting import of #{@rows.size} records."

      result = Product.collection.insert_many(@rows)

       Rails.logger.info "Successfully imported #{result.inserted_count} records."

      {
        success: true,
        total_imported: result.inserted_count
      }
    rescue StandardError => e
      Rails.logger.error "Failed to import records: #{e}"
      { success: false, message: e.message  }
    end

    private

    def merged_row_info(row:, index:)
      { row: index }.merge!(row)
    end
  end
end
