require 'rails_helper'

RSpec.describe Users::OmniauthRouterService, type: :service do
  describe '.call' do
    let(:auth_data) { { email: 'test@example.com', uid: '123', first_name: 'Test', last_name: 'User' } }

    context 'with a known provider' do
      it 'calls the correct service' do
        expect(Users::GoogleOmniauthService).to receive(:call).with(auth: auth_data).and_return(Dry::Monads::Success.new('called google service'))

        result = described_class.call(provider: :google_oauth2, auth: auth_data)

        expect(result).to be_success
        expect(result.value!).to eq('called google service')
      end
    end

    context 'with an unknown provider' do
      it 'returns Failure(:unknown_provider)' do
        result = described_class.call(provider: :unknown_provider, auth: auth_data)

        expect(result).to be_failure
        expect(result.failure).to eq(:unknown_provider)
      end
    end

    context 'when the delegated service succeeds' do
      let(:user) { build_stubbed(:user) }
      before do
        allow(Users::GoogleOmniauthService).to receive(:call).with(auth: auth_data).and_return(Dry::Monads::Success.new(user))
      end

      it 'returns the Success result from the service' do
        result = described_class.call(provider: :google_oauth2, auth: auth_data)
        expect(result).to be_success
        expect(result.value!).to eq(user)
      end
    end

    context 'when the delegated service fails' do
      let(:errors) { { base: ['Something went wrong'] } }
      before do
        allow(Users::GoogleOmniauthService).to receive(:call).with(auth: auth_data).and_return(Dry::Monads::Failure.new(errors))
      end

      it 'returns the Failure result from the service' do
        result = described_class.call(provider: :google_oauth2, auth: auth_data)
        expect(result).to be_failure
        expect(result.failure).to eq(errors)
      end
    end
  end
end
