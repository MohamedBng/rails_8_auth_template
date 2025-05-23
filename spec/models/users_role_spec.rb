require 'rails_helper'

RSpec.describe UsersRole, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
  end
end
