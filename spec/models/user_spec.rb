require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    user = build_stubbed(:user)
    expect(user).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end
end
