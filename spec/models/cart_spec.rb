require 'rails_helper'

RSpec.describe Cart, type: :model do
  it { is_expected.to be_mongoid_document }
  it { is_expected.to have_timestamps }

  describe 'fields' do
    it { is_expected.to have_field(:total_price).of_type(BigDecimal) }
  end
end
