# src/theme/lab.cr
struct Theme::Lab
  getter l : Float64, a : Float64, b : Float64

  def initialize(@l : Float64, @a : Float64, @b : Float64); end

  private def self.rgb_to_xyz(c : Float64) : Float64
    c > 0.04045 ? ((c + 0.055) / 1.055) ** 2.4 : c / 12.92
  end

  private def self.xyz_to_lab(c : Float64) : Float64
    c > 0.008856 ? Math.cbrt(c) : 7.787 * c + 16.0 / 116.0
  end

  def self.from_color(color : Color) : Lab
    r, g, b = rgb_to_xyz(color.r / 255.0), rgb_to_xyz(color.g / 255.0), rgb_to_xyz(color.b / 255.0)

    x = xyz_to_lab((r * 0.4124564 + g * 0.3575761 + b * 0.1804375) / 0.95047)
    y = xyz_to_lab(r * 0.2126729 + g * 0.7151522 + b * 0.0721750)
    z = xyz_to_lab((r * 0.0193339 + g * 0.1191920 + b * 0.9503041) / 1.08883)

    new(116.0 * y - 16.0, 500.0 * (x - y), 200.0 * (y - z))
  end

  private def xyz_to_rgb(c : Float64) : Float64
    c > 0.0031308 ? 1.055 * (c ** (1.0 / 2.4)) - 0.055 : 12.92 * c
  end

  private def lab_to_xyz(c : Float64) : Float64
    c3 = c * c * c
    c3 > 0.008856 ? c3 : (c - 16.0 / 116.0) / 7.787
  end

  def to_color : Color
    y = (@l + 16.0) / 116.0
    x = @a / 500.0 + y
    z = y - @b / 200.0

    xf = lab_to_xyz(x) * 0.95047
    yf = lab_to_xyz(y)
    zf = lab_to_xyz(z) * 1.08883

    r = xf * 3.2404542 - yf * 1.5371385 - zf * 0.4985314
    g = -xf * 0.9692660 + yf * 1.8760108 + zf * 0.0415560
    b = xf * 0.0556434 - yf * 0.2040259 + zf * 1.0572252

    Color.new(channel(xyz_to_rgb(r)), channel(xyz_to_rgb(g)), channel(xyz_to_rgb(b)))
  end

  def lerp(other : Lab, t : Float64) : Lab
    Lab.new(@l + t * (other.l - @l), @a + t * (other.a - @a), @b + t * (other.b - @b))
  end

  private def channel(value : Float64) : UInt8
    (value.clamp(0.0, 1.0) * 255.0).round.to_u8
  end
end
