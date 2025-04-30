require 'rails_helper'

RSpec.describe RolesPermission, type: :model do
  describe 'associations' do
    it { should belong_to(:role) }
    it { should belong_to(:permission) }
  end
end
