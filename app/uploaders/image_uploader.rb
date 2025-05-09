require "image_processing/mini_magick"

class ImageUploader < Shrine
  plugin :determine_mime_type
  plugin :validation_helpers
  plugin :derivatives, create_on_promote: true
  plugin :store_dimensions

  Attacher.validate do
    validate_max_size 5 * 1024 * 1024, message: "is too large (max is 5 MB)"
    validate_mime_type %w[image/jpeg image/png], message: "is not a valid image type"
    validate_extension_inclusion %w[jpg jpeg png], message: "is not a valid image extension"
  end

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    { thumbnail: magick.resize_to_limit!(300, 300) }
  end
end
