# examples/example_helper.cr
require "../src/theme"

# A small helper to quickly generate a 16-color palette for our examples
def generate_mock_palette(base : Theme::Color) : StaticArray(Theme::Color, 16)
  StaticArray(Theme::Color, 16).new do |i|
    # Generate some variations based on the index just for demonstration
    Theme::Color.new(
      (base.r.to_i + i * 5).clamp(0, 255).to_u8,
      (base.g.to_i + i * 5).clamp(0, 255).to_u8,
      (base.b.to_i + i * 5).clamp(0, 255).to_u8
    )
  end
end

