require 'rails_helper'

RSpec.describe Category, type: :model do
  it { is_expected.to be_mongoid_document }
  it { is_expected.to have_timestamps }

  describe 'fields' do
    it { is_expected.to have_field(:name).of_type(String) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:products) }
  end
end
