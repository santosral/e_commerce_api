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
        row_hash = row_hash(row)

        # To validate the headers for the first row only.
        headers = validate_headers(headers, row) unless headers.present?

        Rails.logger.info "Processing row ##{index}: #{row_hash.inspect}"
        product = validate_row(row_hash, index)
        next if product.blank?

        merged_row_info = merged_row_info(row: row_hash, index: index)

        # Next if block given to avoid storing in valid_rows when running in background job
        if block_given?
          yield merged_row_info, product.as_json, index
          next
        end

        @valid_rows << merged_row_info
        @transformed_rows << product
      end

      successful_message = "CSV parsing completed successfully for file: #{@file_path}"
      Rails.logger.info successful_message

      { success: true, message: successful_message }
    rescue StandardError => e
      Rails.logger.error "Error while processing CSV: #{e}"
      { success: true, message: e.message }
    end

    private

    def row_hash(row)
      row.to_h.symbolize_keys
    end

    def merged_row_info(row:, index:)
      hash = { row: index }.merge!(row)
      hash.as_json
    end

    def build_product(row)
      category = Category.find_or_create_by(name: row[:category])
      product = Product.new(
        name: row[:name],
        category: category,
        base_price: row[:default_price],
        quantity: row[:qty].to_i
      )

      product
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

    def validate_row(row, index)
      product = build_product(row)

      if product.valid?
        Rails.logger.info "Valid row ##{index}: #{product.inspect}"

        product
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
