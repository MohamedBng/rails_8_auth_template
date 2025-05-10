require "image_processing/mini_magick"

class ImageUploader < Shrine
  plugin :determine_mime_type
  plugin :validation_helpers
  plugin :derivatives, create_on_promote: true
  plugin :store_dimensions

  VALID_MIME_TYPES = %w[image/jpeg image/png]
  VALID_EXTENSIONS = %w[jpg jpeg png]

  Attacher.validate do
    validate_max_size 5 * 1024 * 1024, message: I18n.t('errors.image.file_size', max_size: 5)
    validate_mime_type VALID_MIME_TYPES, message: I18n.t('errors.image.mime_type', valid_types: VALID_MIME_TYPES.join(', '))
    validate_extension_inclusion VALID_EXTENSIONS, message: I18n.t('errors.image.extension', valid_extensions: VALID_EXTENSIONS.join(', '))
  end

  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    { thumbnail: magick.resize_to_limit!(300, 300) }
  end
end
