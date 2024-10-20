require "csv"

module Products
  class CsvParserService
    VALID_HEADERS = Set.new([ "name", "category", "default_price", "qty" ])

    attr_accessor :file_path
    attr_reader :valid_rows, :invalid_rows, :transformed_rows

    def initialize(file_path)
      @file_path = file_path
      @valid_rows = []
      @invalid_rows = []
      @transformed_rows = []
    end

    def call
      Rails.logger.info "Starting CSV parsing for file: #{@file_path}"

      headers = []
      # CSV.read will load the entire file into memory, which can be problematic for large files.
      # CSV.foreach is more memory-efficient as it reads one row at a time, making it suitable for large files.
      CSV.foreach(@file_path, headers: true, header_converters: :downcase, nil_value: "", strip: true).with_index(1) do |row, index|
        next if row.empty?
        row_hash = row.to_h

        # To validate the headers for the first row only.
        headers = validate_headers(headers, row) unless headers.present?

        Rails.logger.info "Processing row ##{index}: #{row_hash.inspect}"
        product_attributes = validate_row(row_hash, index)

        if product_attributes.present?
          merged_row_info = merged_row_info(row: row_hash, index: index)

          if block_given?
            yield merged_row_info, product_attributes, index
            next
          end

          @valid_rows << merged_row_info(row: row_hash, index: index)
        else
          next
        end

        @transformed_rows << product_attributes
      end

      successful_message = "CSV parsing completed successfully for file: #{@file_path}"
      Rails.logger.info successful_message

      { success: true, message: successful_message }
    rescue StandardError => e
      Rails.logger.error "Error while processing CSV: #{e}"
      { success: true, message: e.message }
    end

    private

    def merged_row_info(row:, index:)
      { "row" => index }.merge!(row)
    end

    def validate_headers(headers, first_row)
      headers = first_row.headers
      first_row_headers = first_row.headers
      Rails.logger.info "Validating headers: #{first_row_headers.join(', ')}"

      if VALID_HEADERS != first_row_headers.to_set
        error_message = "Invalid headers, please set the header with #{VALID_HEADERS.to_a.join(', ')}"
        raise error_message
      end

      first_row_headers
    end

    def validate_row(row_hash, index)
      category = Category.find_or_create_by(name: row_hash["category"])

      product_attributes = {
        name: row_hash["name"],
        category_id: category.id.to_s,
        default_price: row_hash["default_price"].to_f,
        quantity: row_hash["qty"]
      }

      product = Product.new(product_attributes)

      if product.valid?
        Rails.logger.info "Valid row ##{index}: #{product_attributes.inspect}"

        product_attributes.as_json
      else
        @invalid_rows << merged_row_info(row: product.errors.messages, index: index)
        error_message = "Invalid row: #{index}"
        error_message = "Product Errors: #{product.errors.full_messages.join(', ')}"
        Rails.logger.info error_message

        nil
      end
    end
  end
end
