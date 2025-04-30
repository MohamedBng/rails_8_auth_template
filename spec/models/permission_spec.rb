require 'rails_helper'

RSpec.describe Permission, type: :model do
  subject { create(:permission) }

  it 'has a valid factory' do
    permission = build_stubbed(:permission)
    expect(permission).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:roles_permissions).dependent(:destroy_async) }
    it { should have_many(:roles) }
  end
end
