require 'rails_helper'

RSpec.describe Products::ImportJob, type: :model do
  it { is_expected.to be_mongoid_document }
  it { is_expected.to have_timestamps }

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:status).to_allow(Products::ImportJob::STATUSES) }
  end

  describe 'fields' do
    it { is_expected.to have_field(:job_id).of_type(String) }
    it { is_expected.to have_field(:status).of_type(String).with_default_value_of('pending') }
    it { is_expected.to have_field(:valid_rows).of_type(Array).with_default_value_of([]) }
    it { is_expected.to have_field(:invalid_rows).of_type(Array).with_default_value_of([]) }
  end

  describe 'constants' do
    it 'defines valid statuses' do
      expect(Products::ImportJob::STATUSES).to match_array([ "pending", "processing", "success", "error" ])
    end
  end
end
