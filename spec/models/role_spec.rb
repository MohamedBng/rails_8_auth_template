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
    it { should have_many(:users_roles).dependent(:destroy) }
    it { should have_many(:permissions) }
    it { should have_many(:roles_permissions).dependent(:destroy) }
  end

  describe 'scopes' do
    context 'with_users_count' do
      it 'returns roles with correct users_count' do
        role_with_users = create(:role)

        create_list(:user, 3).each do |user|
          create(:users_role, user: user, role: role_with_users)
        end

        role_without_users = create(:role)

        roles = Role.with_users_count

        result_with_users = roles.find { |r| r.id == role_with_users.id }
        expect(result_with_users.users_count.to_i).to eq(3)

        result_without_users = roles.find { |r| r.id == role_without_users.id }
        expect(result_without_users.users_count.to_i).to eq(0)
      end
    end
  end
end
