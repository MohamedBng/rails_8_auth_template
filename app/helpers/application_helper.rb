module ApplicationHelper
  # Determines the ideal text color (black or white) for a given hex background color
  # to ensure good contrast.
  def ideal_text_color(hex_background_color)
    return "#000000" if hex_background_color.blank? # Default to black for blank/nil

    hex_color = hex_background_color.gsub("#", "")

    # Ensure hex_color is valid (6 characters) after removing #
    return "#000000" unless hex_color.match?(/^[0-9a-fA-F]{6}$/)

    r = hex_color[0..1].hex
    g = hex_color[2..3].hex
    b = hex_color[4..5].hex

    # Formula for perceived brightness (standard for sRGB)
    # See: https://www.w3.org/TR/WCAG20-TECHS/G17.html#G17-tests
    # Luminance (Y) = 0.2126 R + 0.7152 G + 0.0722 B
    # where R, G, B are 0-1. Here, we use 0-255 and a threshold of 128-186.
    # A simpler formula often used is (R*299 + G*587 + B*114) / 1000
    brightness = (r * 299 + g * 587 + b * 114) / 1000

    brightness > 150 ? "#000000" : "#FFFFFF" # Threshold can be adjusted (128-186 is common)
  end
end
