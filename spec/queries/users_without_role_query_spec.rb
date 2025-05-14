require 'rails_helper'

RSpec.describe UsersWithoutRoleQuery do
  let(:role) { create(:role) }
  let!(:user_with_role) { create(:user) }
  let!(:user_without_role) { create(:user) }

  before do
    user_with_role.roles << role
  end

  describe '.call' do
    it 'returns users without the specified role' do
      result = described_class.call(role: role)

      expect(result[:users]).to include(user_without_role)
      expect(result[:users]).not_to include(user_with_role)
    end

    context 'with pagination' do
      let!(:extra_users) { create_list(:user, 5) }

      it 'paginates results with default values' do
        result = described_class.call(role: role)

        expect(result[:users].limit_value).to eq(described_class::DEFAULT_PER_PAGE)
        expect(result[:users].current_page).to eq(1)
      end

      it 'respects custom pagination parameters' do
        result = described_class.call(role: role, page: 2, per_page: 3)

        expect(result[:users].limit_value).to eq(3)
        expect(result[:users].current_page).to eq(2)
      end
    end

    context 'with search parameters' do
      let!(:john_doe) { create(:user, first_name: 'John', last_name: 'Doe') }
      let!(:jane_doe) { create(:user, first_name: 'Jane', last_name: 'Doe') }

      it 'filters users by first name' do
        result = described_class.call(
          role: role,
          params: { first_name_cont: 'John' }
        )

        expect(result[:users]).to include(john_doe)
        expect(result[:users]).not_to include(jane_doe)
      end

      it 'filters users by last name' do
        result = described_class.call(
          role: role,
          params: { last_name_cont: 'Doe' }
        )

        expect(result[:users]).to include(john_doe, jane_doe)
      end
    end

    it 'orders users by first name ascending' do
      alice = create(:user, first_name: 'Alice')
      bob = create(:user, first_name: 'Bob')

      result = described_class.call(role: role)

      expect(result[:users].to_a).to eq([ alice, bob, user_without_role ].sort_by(&:first_name))
    end

    it 'includes the search object in the result' do
      result = described_class.call(role: role)

      expect(result[:search]).to be_a(Ransack::Search)
    end
  end
end
