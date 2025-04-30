require 'rails_helper'

RSpec.describe Role, type: :model do
  subject { create(:role) }

  it 'has a valid factory' do
    role = build_stubbed(:role)
    expect(role).to be_valid
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:users) }
    it { should have_many(:users_roles).dependent(:destroy_async) }
    it { should have_many(:permissions) }
    it { should have_many(:roles_permissions).dependent(:destroy_async) }
  end
end
