require 'rails_helper'

RSpec.describe RoleDecorator do
  let(:role) { create(:role, name: 'test_role', color: '#FF0000').decorate }

  describe '#name' do
    it 'returns the titleized role name' do
      expect(role.name).to eq('Test Role')
    end
  end

  describe '#badge' do
    it 'returns an HTML badge with correct styling' do
      expected_badge_html = '<span class="badge badge-soft" style="background-color: #FF0000; color: #FFFFFF;">Test Role</span>'
      expect(role.badge).to eq(expected_badge_html)
    end
  end
end
