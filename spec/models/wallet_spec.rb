require 'rails_helper'

RSpec.describe Wallet, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to define_enum_for(:status).with_values({ active: 1, inactive: 0 }) }

  it { is_expected.to belong_to(:user) }
end
