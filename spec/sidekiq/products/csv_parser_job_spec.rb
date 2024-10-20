require 'rails_helper'

RSpec.describe Products::CsvParserJob, type: :job do
  let(:file_path) { 'spec/fixtures/files/products.csv' }
  let(:raw_data) { { "row" => 1, "category" => "Apple", "default_price" => 20.0, "qty" => 10 } }
  let(:product_attribute) { { "name" => 'Product A', "category_id" => "11111111111", "default_price" => 20.0, "qty" => 10 } }
  let(:import_job) { create(:import_job) }
  let(:service) { instance_double(Products::CsvParserService) }

  before do
    Sidekiq::Testing.fake!
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
    allow(Products::ImportJob).to receive(:find).with(import_job.id.to_s).and_return(import_job)
    allow(File).to receive(:delete).and_return(true)
  end

  describe '#perform' do
    before do
      allow(Products::CsvParserService).to receive(:new).with(file_path).and_return(service)
    end

    context 'when CSV parsing is successful' do
      before do
        allow(service).to receive(:call).and_yield({ name: 'Product A', category_id: 1 }, 1)
        allow(service).to receive(:call).and_return({ success: true, message: anything })
        allow(service).to receive(:valid_rows).and_return([ name: 'Product A' ])
        allow(service).to receive(:invalid_rows).and_return([])
        allow(import_job).to receive(:update!).and_call_original
      end

      it 'updates the import status to success and processes batches' do
        expect(import_job).to receive(:update!).with(status: "processing")
        expect(import_job).to receive(:update!).with(status: "success", invalid_rows: anything)

        Products::CsvParserJob.perform_async(file_path, import_job.id.to_s)

        expect { described_class.drain }.to change { import_job.reload.status }.from("pending").to("success")
      end

      it 'queues batch imports correctly' do
        stub_const("Products::CsvParserJob::BATCH_SIZE", 1)
        allow(service).to receive(:call).and_yield(raw_data, product_attribute, 1)

        expect {
          Products::CsvParserJob.perform_async(file_path, import_job.id.to_s)
          described_class.drain
        }.to change(Products::CsvBatchImportJob.jobs, :size).by(1)
      end
    end

    context 'when CSV parsing fails' do
      before do
        allow(service).to receive(:call).and_raise(StandardError.new('Parsing error'))
        allow(import_job).to receive(:update!).and_call_original
      end

      it 'updates the import status to error' do
        expect(import_job).to receive(:update!).with(status: "processing")
        expect(import_job).to receive(:update!).with(status: "error")

        Products::CsvParserJob.perform_async(file_path, import_job.id.to_s)

        expect { described_class.drain }.to change { import_job.reload.status }.from("pending").to("error")
      end

      it 'logs the error' do
        Products::CsvParserJob.perform_async(file_path, import_job.id.to_s)
        expect { described_class.drain }.to change { import_job.reload.status }.from("pending").to("error")
        expect(Rails.logger).to have_received(:error).with(/CsvParserJob failed for file:/)
      end
    end

    context 'when an exception occurs' do
      before do
        allow(service).to receive(:call).and_yield(raw_data, product_attribute, 1)
        allow(service).to receive(:call).and_return({ success: false, message: anything })
        allow(File).to receive(:delete).with(file_path).and_raise(StandardError.new('File error'))
      end

      it 'logs the error and ensures file is attempted to be deleted' do
        expect(Rails.logger).to receive(:error).with(/Failed to delete temporary file/)
        expect(File).to receive(:delete).with(file_path)

        Products::CsvParserJob.perform_async(file_path, import_job.id.to_s)

        expect { described_class.drain }.to change { import_job.reload.status }.from("pending").to("error")
      end
    end
  end
end
