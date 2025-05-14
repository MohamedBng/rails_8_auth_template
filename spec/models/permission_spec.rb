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
    it { should have_many(:roles_permissions).dependent(:destroy) }
    it { should have_many(:roles) }
  end

  describe 'scopes' do
    describe '.without_role' do
      let(:role) { create(:role) }
      let!(:permission_in_role) { create(:permission) }
      let!(:permission_not_in_role) { create(:permission) }

      before do
        role.permissions << permission_in_role
      end

      it 'returns permissions not associated with the given role' do
        expect(Permission.without_role(role)).to include(permission_not_in_role)
        expect(Permission.without_role(role)).not_to include(permission_in_role)
      end
    end
  end
end
