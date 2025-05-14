require 'rails_helper'

RSpec.describe PermissionsWithoutRoleQuery do
  describe '.call' do
    let(:role) { create(:role) }
    let!(:permission_in_role) { create(:permission, name: 'edit_users') }
    let!(:permission_not_in_role) { create(:permission, name: 'delete_users') }
    let!(:another_permission) { create(:permission, name: 'manage_roles') }

    before do
      role.permissions << permission_in_role
    end

    it 'returns permissions not associated with the role' do
      result = described_class.call(role: role)

      expect(result[:permissions]).to include(permission_not_in_role, another_permission)
      expect(result[:permissions]).not_to include(permission_in_role)
    end

    context 'with search params' do
      it 'filters permissions by name' do
        result = described_class.call(
          role: role,
          params: { name_cont: 'delete' }
        )

        expect(result[:permissions]).to include(permission_not_in_role)
        expect(result[:permissions]).not_to include(another_permission, permission_in_role)
      end
    end

    context 'with pagination' do
      let!(:extra_permissions) { create_list(:permission, 5) }

      it 'paginates the results' do
        result = described_class.call(
          role: role,
          per_page: 2
        )

        expect(result[:permissions].size).to eq(2)
        expect(result[:permissions].total_count).to eq(7) # 2 initial + 5 extra permissions not in role
      end
    end

    it 'returns the search object' do
      result = described_class.call(role: role)

      expect(result[:search]).to be_a(Ransack::Search)
    end
  end
end
