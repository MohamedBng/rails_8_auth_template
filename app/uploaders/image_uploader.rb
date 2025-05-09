require "image_processing/mini_magick"

class ImageUploader < Shrine
  # Plugins
  plugin :determine_mime_type
  plugin :validation_helpers
  plugin :derivatives
  plugin :store_dimensions

  # Validations
  Attacher.validate do
    validate_max_size 5 * 1024 * 1024, message: "is too large (max is 5 MB)"
    validate_mime_type %w[image/jpeg image/png image/gif image/webp], message: "is not a valid image type"
    validate_extension_inclusion %w[jpg jpeg png gif webp], message: "is not a valid image extension"
  end

  # Derivatives (versions)
  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {
      thumbnail: magick.resize_to_limit!(300, 300)
    }
  end
end
