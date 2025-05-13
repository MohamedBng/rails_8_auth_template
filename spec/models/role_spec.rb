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

    context 'with_permissions_count' do
      it 'returns roles with correct permissions_count' do
        role_with_permissions = create(:role)
        create_list(:permission, 2).each do |permission|
          create(:roles_permission, role: role_with_permissions, permission: permission)
        end

        role_without_permissions = create(:role)

        roles = Role.with_permissions_count

        result_with_permissions = roles.find { |r| r.id == role_with_permissions.id }
        expect(result_with_permissions.permissions_count.to_i).to eq(2)

        result_without_permissions = roles.find { |r| r.id == role_without_permissions.id }
        expect(result_without_permissions.permissions_count.to_i).to eq(0)
      end
    end
  end

  describe '#add_users!' do
    let(:role) { create(:role) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }

    context 'when adding new users' do
      it 'associates the users with the role' do
        expect {
          role.add_users!([ user1.id, user2.id ])
        }.to change { role.users.count }.by(2)
        expect(role.users).to include(user1, user2)
      end
    end

    context 'when user_ids array is empty' do
      it 'does not change the associated users' do
        expect {
          role.add_users!([])
        }.not_to change { role.users.count }
      end
    end

    context 'when some user_ids are invalid' do
      it 'associates only valid users' do
        expect {
          role.add_users!([ user1.id, 'invalid-id', user3.id ])
        }.to change { role.users.count }.by(2)
        expect(role.users).to include(user1, user3)
        expect(role.users).not_to include(user2)
      end
    end

    context 'when some users are already associated' do
      before do
        role.users << user1
      end

      it 'associates only new users and does not duplicate' do
        expect {
          role.add_users!([ user1.id, user2.id, user3.id ])
        }.to change { role.users.count }.by(2)
        expect(role.users).to include(user1, user2, user3)
        expect(role.users.where(id: user1.id).count).to eq(1)
      end
    end

    context 'when all provided user_ids are already associated' do
      before do
        role.users << user1
        role.users << user2
      end

      it 'does not change the associated users' do
        expect {
          role.add_users!([ user1.id, user2.id ])
        }.not_to change { role.users.count }
        expect(role.users).to include(user1, user2)
      end
    end
  end
end
