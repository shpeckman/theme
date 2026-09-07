# src/theme/scheme.cr
require "json"
require "yaml"

class Theme::Scheme
  include JSON::Serializable
  include YAML::Serializable

  module PaletteConverter
    def self.to_json(value : StaticArray(Color, 16), json : JSON::Builder)
      json.array do
        value.each &.to_json(json)
      end
    end

    def self.from_json(pull : JSON::PullParser) : StaticArray(Color, 16)
      colors = Array(Color).new(pull)
      if colors.size != 16
        raise JSON::ParseException.new("Expected exactly 16 colors for palette, got #{colors.size}", pull.line_number, pull.column_number)
      end

      palette = uninitialized StaticArray(Color, 16)
      16.times { |i| palette[i] = colors[i] }
      palette
    end

    def self.to_yaml(value : StaticArray(Color, 16), yaml : YAML::Nodes::Builder)
      yaml.sequence do
        value.each &.to_yaml(yaml)
      end
    end

    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node) : StaticArray(Color, 16)
      colors = Array(Color).new(ctx, node)
      node.raise("Expected exactly 16 colors for palette, got #{colors.size}") if colors.size != 16

      palette = uninitialized StaticArray(Color, 16)
      16.times { |i| palette[i] = colors[i] }
      palette
    end
  end

  getter name : String?

  @[JSON::Field(converter: Theme::Scheme::PaletteConverter)]
  @[YAML::Field(converter: Theme::Scheme::PaletteConverter)]
  getter palette : StaticArray(Color, 16)

  {% for field in %w(foreground background) %}
    getter {{field.id}} : Color?
    def {{field.id}}_hex : String?
      @{{field.id}}.try(&.hex)
    end
  {% end %}

  @[JSON::Field(ignore: true)]
  @[YAML::Field(ignore: true)]
  @_generated_256 : StaticArray(Color, 256)?

  @[JSON::Field(ignore: true)]
  @[YAML::Field(ignore: true)]
  @_generated_256_harmonious : StaticArray(Color, 256)?

  def initialize(
    @palette : StaticArray(Color, 16),
    @name : String? = nil,
    @foreground : Color? = nil,
    @background : Color? = nil,
  )
  end

  def self.from_hex(
    palette : Indexable(String),
    name : String? = nil,
    foreground : String? = nil,
    background : String? = nil,
  ) : self
    raise ArgumentError.new("Palette must contain exactly 16 colors") if palette.size != 16

    parsed_palette = uninitialized StaticArray(Color, 16)
    16.times { |i| parsed_palette[i] = Color.parse(palette[i]) }

    new(
      palette: parsed_palette,
      name: name,
      foreground: foreground ? Color.parse(foreground) : nil,
      background: background ? Color.parse(background) : nil
    )
  end

  def [](index : Int) : Color
    @palette[index]
  end

  def dark? : Bool
    (@background || @palette[0]).perceived_luminance < 0.5
  end

  def light? : Bool
    !dark?
  end

  def fade_to(target : Scheme, steps : Int) : Array(Scheme)
    raise ArgumentError.new("steps must be at least 2") if steps < 2
    Array(Scheme).new(steps) { |i| interpolate_scheme(self, target, i / (steps - 1).to_f64) }
  end

  private def interpolate_scheme(a : Scheme, b : Scheme, t : Float64) : Scheme
    palette = uninitialized StaticArray(Color, 16)
    16.times { |i| palette[i] = interpolate_color(a.palette[i], b.palette[i], t).as(Color) }

    Scheme.new(
      palette: palette,
      name: a.name,
      foreground: interpolate_color(a.foreground, b.foreground, t),
      background: interpolate_color(a.background, b.background, t)
    )
  end

  private def interpolate_color(c1 : Color?, c2 : Color?, t : Float64) : Color?
    return c1 || c2 if c1.nil? || c2.nil?
    Lab.from_color(c1).lerp(Lab.from_color(c2), t).to_color
  end

  def generate_256(*, harmonious : Bool = false) : StaticArray(Color, 256)
    harmonious ? (@_generated_256_harmonious ||= build_256(harmonious: true)) : (@_generated_256 ||= build_256(harmonious: false))
  end

  private def build_256(*, harmonious : Bool) : StaticArray(Color, 256)
    bg, fg = @background || @palette[0], @foreground || @palette[7]
    base = uninitialized StaticArray(Lab, 8)
    8.times { |i| base[i] = Lab.from_color(i == 0 ? bg : (i == 7 ? fg : @palette[i])) }

    base[0], base[7] = base[7], base[0] if base[7].l < base[0].l && !harmonious

    result = uninitialized StaticArray(Color, 256)
    16.times { |i| result[i] = @palette[i] }

    idx = 16
    6.times do |ri|
      tr = ri / 5.0
      c0, c1, c2, c3 = base[0].lerp(base[1], tr), base[2].lerp(base[3], tr), base[4].lerp(base[5], tr), base[6].lerp(base[7], tr)
      6.times do |gi|
        tg = gi / 5.0
        c4, c5 = c0.lerp(c1, tg), c2.lerp(c3, tg)
        6.times do |bi|
          result[idx] = c4.lerp(c5, bi / 5.0).to_color
          idx += 1
        end
      end
    end

    24.times { |i| result[idx] = base[0].lerp(base[7], (i + 1) / 25.0).to_color; idx += 1 }
    result
  end
end
