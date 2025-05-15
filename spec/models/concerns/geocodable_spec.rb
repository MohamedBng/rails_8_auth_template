require 'rails_helper'

RSpec.describe Geocodable do
  let(:user) { build(:user) }
  
  describe '#full_address' do
    it 'correctly combines address components' do
      user.street = '123 Main St'
      user.city = 'Paris'
      user.postal_code = '75001'
      user.country = 'France'
      
      expect(user.full_address).to eq('123 Main St, Paris, 75001, France')
    end
    
    it 'handles missing components' do
      user.street = '123 Main St'
      user.city = 'Paris'
      
      expect(user.full_address).to eq('123 Main St, Paris')
    end
  end
  
  describe '#address_changed?' do
    it 'returns true when street changes' do
      user = create(:user, street: '123 Main St')
      user.street = '456 New St'
      
      expect(user.address_changed?).to be true
    end
    
    it 'returns true when city changes' do
      user = create(:user, city: 'Paris')
      user.city = 'Lyon'
      
      expect(user.address_changed?).to be true
    end
    
    it 'returns true when postal_code changes' do
      user = create(:user, postal_code: '75001')
      user.postal_code = '69001'
      
      expect(user.address_changed?).to be true
    end
    
    it 'returns true when country changes' do
      user = create(:user, country: 'France')
      user.country = 'Belgium'
      
      expect(user.address_changed?).to be true
    end
    
    it 'returns false when non-address fields change' do
      user = create(:user, first_name: 'John')
      user.first_name = 'Jane'
      
      expect(user.address_changed?).to be false
    end
  end
  
  describe '#geocodable?' do
    it 'returns true when city is present' do
      user.city = 'Paris'
      expect(user.geocodable?).to be true
    end
    
    it 'returns true when postal_code is present' do
      user.postal_code = '75001'
      expect(user.geocodable?).to be true
    end
    
    it 'returns false when both city and postal_code are missing' do
      user.street = '123 Main St'
      user.country = 'France'
      expect(user.geocodable?).to be false
    end
  end
  
  describe '#geocode_with_error_handling' do
    it 'returns true when geocoding succeeds' do
      allow(user).to receive(:geocode).and_return([48.8566, 2.3522])
      expect(user.geocode_with_error_handling).to be true
    end
    
    it 'adds an error and returns false when geocoding fails' do
      allow(user).to receive(:geocode).and_raise(Geocoder::Error.new("Invalid address"))
      expect(user.geocode_with_error_handling).to be false
      expect(user.errors[:base]).to include(I18n.t('errors.messages.geocoding.service_error', message: "Invalid address"))
    end
  end
  
  describe 'validation of non-existent locations' do
    it 'detects non-existent city when geocoding directly' do
      user = build(:user,
        street: '123 Fake Street',
        city: 'NonExistentCity12345',
        postal_code: '99999',
        country: 'Nowhere'
      )
      
      allow(Geocoder).to receive(:search).with(any_args).and_return([])
      
      user.geocode
      
      expect(user.latitude).to be_nil
      expect(user.longitude).to be_nil
    end
    
    it 'prevents saving a user with a non-existent city' do
      user = build(:user,
        street: '123 Fake Street',
        city: 'NonExistentCity12345',
        postal_code: '99999',
        country: 'Nowhere'
      )
      
      allow(Geocoder).to receive(:search).with(any_args).and_return([])
      
      expect(user).not_to be_valid
      expect(user.errors[:base]).to include(I18n.t('errors.messages.geocoding.address_not_found'))
      expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
    
    it 'allows saving a user with a valid city' do
      user = build(:user,
        street: '123 Main Street',
        city: 'Paris',
        postal_code: '75001',
        country: 'France'
      )
      
      mock_result = double("geocoder_result", latitude: 48.8566, longitude: 2.3522)
      allow(Geocoder).to receive(:search).with(any_args).and_return([mock_result])
      
      expect(user).to be_valid
      
      expect { user.save! }.not_to raise_error
      
      expect(user.latitude).to eq(48.8566)
      expect(user.longitude).to eq(2.3522)
    end
  end
end
