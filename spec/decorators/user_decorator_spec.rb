require 'rails_helper'

RSpec.describe UserDecorator do
  include ActiveSupport::Testing::TimeHelpers

  let(:created_at) { Time.zone.parse('2025-01-01 10:00:00') }
  let(:user) do
    build_stubbed(
      :user,
      first_name: 'John',
      last_name:  'Doe',
      created_at: created_at
    )
  end

  subject(:decorator) { described_class.decorate(user) }

  describe '#full_name' do
    it 'concatenates first and last name' do
      expect(decorator.full_name).to eq 'John Doe'
    end
  end

  describe '#joined_on' do
    around do |example|
      travel_to created_at do
        example.run
      end
    end

    it 'formats created_at with the default :long format' do
      expect(decorator.joined_on)
        .to eq I18n.l(created_at, format: :long)
    end

    it 'allows a custom format' do
      expect(decorator.joined_on(format: :short))
        .to eq I18n.l(created_at, format: :short)
    end
  end

  describe '#confirmation_badge' do
    context 'when user is confirmed' do
      before { user.confirmed_at = Time.zone.now }

      it 'returns a success badge' do
        expect(decorator.confirmation_badge).to include('Confirmed')
        expect(decorator.confirmation_badge).to include('badge-success')
      end
    end

    context 'when user is not confirmed' do
      before { user.confirmed_at = nil }

      it 'returns a warning badge' do
        expect(decorator.confirmation_badge).to include('Unconfirmed')
        expect(decorator.confirmation_badge).to include('badge-warning')
      end
    end
  end
end
