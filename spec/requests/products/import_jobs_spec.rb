require 'rails_helper'

RSpec.describe 'Products::ImportJobs', type: :request do
  let(:valid_headers) {
    { 'Accept' => 'application/json' }
  }
  let(:valid_file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/products/valid.csv'), 'text/csv') }
  let(:import_job_params) { { import_job: { file: valid_file } } }

  describe 'POST /products/import_jobs' do
    context 'with valid parameters' do
      it 'creates a new import job' do
        post import_jobs_products_url, params: import_job_params, headers: valid_headers

        expect(response).to have_http_status(:created)
        expect(json_response).to include('id', 'status', 'job_id')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error' do
        post import_jobs_products_url, params: { import_job: {} }, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end
    end

    context 'when an exception occurs' do
      before do
        allow(Products::ImportJob).to receive(:create!).and_raise(StandardError.new('Some error'))
      end

      it 'returns an error message' do
        post import_jobs_products_url, params: import_job_params, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('errors')
      end
    end
  end

  describe 'GET /products/import_jobs/:id' do
    let!(:import_job) { Products::ImportJob.create!(status: 'pending') }

    context 'with a valid id' do
      it 'retrieves the import job' do
        get import_job_products_url(import_job), headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(json_response).to include('id', 'status')
        expect(json_response['id']).to eq(import_job.id.to_s)
      end
    end

    context 'with an invalid id' do
      it 'returns a not found error' do
        get "/products/import_jobs/99999"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
