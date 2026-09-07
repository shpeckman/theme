# src/theme/color.cr
struct Theme::Color
  HEX_DIGITS = "0123456789abcdef".to_slice

  getter r : UInt8, g : UInt8, b : UInt8

  def initialize(@r : UInt8, @g : UInt8, @b : UInt8); end

  def self.parse(hex : String) : Color
    parse?(hex) || raise ParseError.new("invalid hex color: #{hex.inspect}")
  end

  def self.parse?(hex : String) : Color?
    s = hex.lstrip('#')
    return nil unless s.bytesize == 6
    r, g, b = s.byte_slice(0, 2).to_u8?(16), s.byte_slice(2, 2).to_u8?(16), s.byte_slice(4, 2).to_u8?(16)
    new(r, g, b) if r && g && b
  end

  def hex : String
    String.new(7) do |buffer|
      buffer[0] = '#'.ord.to_u8
      buffer[1] = HEX_DIGITS[@r >> 4]
      buffer[2] = HEX_DIGITS[@r & 0x0f]
      buffer[3] = HEX_DIGITS[@g >> 4]
      buffer[4] = HEX_DIGITS[@g & 0x0f]
      buffer[5] = HEX_DIGITS[@b >> 4]
      buffer[6] = HEX_DIGITS[@b & 0x0f]
      {7, 7}
    end
  end

  def luminance : Float64
    0.2126 * component_luminance(@r) + 0.7152 * component_luminance(@g) + 0.0722 * component_luminance(@b)
  end

  def contrast(other : Color) : Float64
    l1, l2 = {luminance, other.luminance}.minmax
    (l2 + 0.05) / (l1 + 0.05)
  end

  def perceived_luminance : Float64
    (0.299 * @r + 0.587 * @g + 0.114 * @b) / 255.0
  end

  private def component_luminance(c : UInt8) : Float64
    n = c.to_f64 / 255.0
    n <= 0.03928 ? n / 12.92 : ((n + 0.055) / 1.055) ** 2.4
  end
end
