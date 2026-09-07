# src/theme/color.cr
require "json"
require "yaml"

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

  # Builds a color from gamma-encoded sRGB components in the range 0.0-1.0.
  # Out-of-range components are clamped.
  def self.from_floats(r : Float64, g : Float64, b : Float64) : Color
    new((r.clamp(0.0, 1.0) * 255).round.to_u8,
      (g.clamp(0.0, 1.0) * 255).round.to_u8,
      (b.clamp(0.0, 1.0) * 255).round.to_u8)
  end

  # Converts a gamma-encoded Display P3 color (components in 0.0-1.0) to sRGB.
  def self.from_p3(r : Float64, g : Float64, b : Float64) : Color
    lin = {r, g, b}.map { |c| transfer_decode(c) }
    x   = lin[0] * 0.48657095 + lin[1] * 0.26566769 + lin[2] * 0.19821729
    y   = lin[0] * 0.22897456 + lin[1] * 0.69173852 + lin[2] * 0.07928691
    z   = lin[0] * 0.0 + lin[1] * 0.04511338 + lin[2] * 1.04394437
    sr  = x * 3.2404542 + y * -1.5371385 + z * -0.4985314
    sg  = x * -0.9692660 + y * 1.8760108 + z * 0.0415560
    sb  = x * 0.0556434 + y * -0.2040259 + z * 1.0572252
    from_floats(transfer_encode(sr), transfer_encode(sg), transfer_encode(sb))
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

  def to_json(json : JSON::Builder)
    json.string(hex)
  end

  def self.new(pull : JSON::PullParser)
    parse(pull.read_string)
  end

  def to_yaml(yaml : YAML::Nodes::Builder)
    yaml.scalar(hex)
  end

  def self.new(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
    node.raise("Expected scalar") unless node.is_a?(YAML::Nodes::Scalar)
    parse(node.value)
  end

  private def component_luminance(c : UInt8) : Float64
    n = c.to_f64 / 255.0
    n <= 0.03928 ? n / 12.92 : ((n + 0.055) / 1.055) ** 2.4
  end

  private def self.transfer_decode(c : Float64) : Float64
    c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
  end

  private def self.transfer_encode(c : Float64) : Float64
    c <= 0.0031308 ? c * 12.92 : 1.055 * (c ** (1 / 2.4)) - 0.055
  end
end
