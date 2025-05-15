module Geocodable
  extend ActiveSupport::Concern

  included do
    geocoded_by :full_address
    after_validation :validate_address, if: ->(obj) { obj.address_changed? && obj.geocodable? }

    validate :address_must_exist, if: :geocodable?
  end

  def address_changed?
    street_changed? || city_changed? || postal_code_changed? || country_changed?
  end

  def full_address
    parts = [ street, city, postal_code, country ].reject(&:blank?)
    parts.any? ? parts.join(", ").titleize : nil
  end


  def geocodable?
    city.present? || postal_code.present?
  end

  def geocode_with_error_handling
    begin
      geocode
      true
    rescue Geocoder::Error => e
      errors.add(:base, I18n.t("errors.messages.geocoding.service_error", message: e.message))
      false
    end
  end

  def validate_address
    return if latitude.present? && longitude.present? && !address_changed?

    results = Geocoder.search(full_address)

    if results.empty?
      errors.add(:base, I18n.t("errors.messages.geocoding.address_not_found"))
      false
    else
      self.latitude = results.first.latitude
      self.longitude = results.first.longitude
      true
    end
  end

  def address_must_exist
    return unless address_changed?

    return if latitude.present? && longitude.present? && !address_changed?

    validate_address
  end
end
