require "rails_helper"

RSpec.describe Products::CsvParserService do
  let(:csv_path) { 'spec/fixtures/files/products/valid.csv' }
  let(:service) { described_class.new(csv_path) }
  let(:result) { service.call }

  describe '#initialize' do
    it { expect(service.file_path).to eq(csv_path) }
    it { expect(service.valid_rows).to eq([]) }
    it { expect(service.invalid_rows).to eq([]) }
    it { expect(service.transformed_rows).to eq([]) }
  end

  describe '#call' do
    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    context 'when headers are valid' do
      before { result }

      it { expect(service.valid_rows.size).to eq(50) }
      it { expect(service.invalid_rows.size).to eq(0) }
      it { expect(service.transformed_rows.size).to eq(50) }
    end

    context 'when headers are invalid' do
      let(:csv_path) { 'spec/fixtures/files/products/invalid_headers.csv' }

      before { result }

      it { expect(Rails.logger).to have_received(:error).with(/Invalid headers/) }
      it { expect(result[:success]).to eq(true) }
      it { expect(result[:message]).to match(/Invalid headers/) }
    end

    context 'when a row is invalid' do
      let(:csv_path) { 'spec/fixtures/files/products/invalid_data.csv' }

      before { result }

      it { expect(service.valid_rows.size).to eq(0) }
      it { expect(service.invalid_rows.size).to eq(1) }
    end

    context 'when an error occurs during processing' do
      before do
        allow(CSV).to receive(:foreach).and_raise(StandardError.new('Some error occurred'))
        result
      end

      it { expect(Rails.logger).to have_received(:error).with(/Error while processing CSV/) }
      it { expect(result[:success]).to eq(true) }
      it { expect(result[:message]).to eq('Some error occurred') }
    end
  end
end
