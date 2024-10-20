require "rails_helper"

RSpec.describe Products::CsvImportService do
  let(:rows) { [ { name: 'Product A', category_id: 1, default_price: 10.0, quantity: 5 } ] }
  let(:service) { described_class.new(rows) }
  let(:response) { service.call }

  describe '#initialize' do
    it 'initializes with the correct rows' do
      expect(service.rows).to eq(rows)
    end
  end

  describe '#call' do
    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    context 'when records are imported successfully' do
      let(:result) { double('result', inserted_count: 1) }

      before do
        allow(Product).to receive_message_chain(:collection, :insert_many).and_return(result)
        response
      end

      it { expect(Rails.logger).to have_received(:info).with(/Starting import/) }
      it { expect(Rails.logger).to have_received(:info).with(/Successfully imported 1 records/) }
      it { expect(response).to eq({ success: true, total_imported: 1 }) }
    end

    context 'when an error occurs during import' do
      before do
        allow(Product).to receive_message_chain(:collection, :insert_many).and_raise(StandardError.new('Database error'))
        response
      end

      it { expect(Rails.logger).to have_received(:error).with(/Failed to import records:/) }
      it { expect(response).to eq({ success: false, message: 'Database error' }) }
    end
  end
end
