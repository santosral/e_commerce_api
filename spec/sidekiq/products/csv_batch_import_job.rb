require 'rails_helper'

RSpec.describe Products::CsvBatchImportJob, type: :job do
  let(:import_job) { create(:import_job) }
  let(:batch_products) do
    [
      { "name" => "Product 1", "category_id" => "507f1f77bcf86cd799439011", "default_price" => "10.0", "qty" => "5" },
      { "name" => "Product 2", "category_id" => "507f1f77bcf86cd799439012", "default_price" => "20.0", "qty" => "3" }
    ]
  end

  before do
    allow(Products::ImportJob).to receive(:find).with(import_job.id).and_return(import_job)
  end

  context 'when job is enqueued' do
    it 'enqueues the job' do
      expect {
        Products::CsvBatchImportJob.perform_async(batch_products, import_job.id.to_s)
      }.to change(Products::CsvBatchImportJob.jobs, :size).by(1)
    end
  end

  context 'when the job is performed successfully' do
    let(:service_double) { instance_double(Products::CsvImportService, call: { success: true }) }

    before do
      allow(Products::CsvImportService).to receive(:new).and_return(service_double)
    end

    it 'updates the import status to success' do
      expect {
        described_class.new.perform(batch_products, import_job.id.to_s)
      }.to change { import_job.reload.status }.to('success')
    end

    it 'logs success' do
      expect(Rails.logger).to receive(:info).with(anything).twice
      described_class.new.perform(batch_products, import_job.id)
    end
  end

  context 'when the job fails' do
    let(:service_double) { instance_double(Products::CsvImportService, call: { success: false }) }

    before do
      allow(Products::CsvImportService).to receive(:new).and_return(service_double)
    end

    it 'updates the import status to error' do
      expect {
        described_class.new.perform(batch_products, import_job.id)
      }.to change { import_job.reload.status }.to('error')
    end

    it 'logs error' do
      expect(Rails.logger).to receive(:error).with(anything)
      described_class.new.perform(batch_products, import_job.id)
    end
  end

  context 'when an exception occurs' do
    before do
      allow(Products::CsvImportService).to receive(:new).and_raise(StandardError.new("An error occurred"))
    end

    it 'updates the import status to error' do
      expect {
        described_class.new.perform(batch_products, import_job.id)
      }.to change { import_job.reload.status }.to('error')
    end

    it 'logs the error message' do
      expect(Rails.logger).to receive(:error).with(/Failed to import batch/)
      described_class.new.perform(batch_products, import_job.id)
    end
  end
end
