# examples/03_scheme_generation.cr
require "./example_helper"

# Create a dark scheme
dark_palette = generate_mock_palette(Theme::Color.parse("#101010"))
dark_scheme = Theme::Scheme.new(
  name: "My Dark Theme",
  palette: dark_palette,
  background: Theme::Color.parse("#1E1E1E"),
  foreground: Theme::Color.parse("#D4D4D4")
)

puts "--- Theme Scheme Info ---"
puts "Name:       #{dark_scheme.name}"
puts "Background: #{dark_scheme.background_hex}"
puts "Foreground: #{dark_scheme.foreground_hex}"
puts "Is Dark?    #{dark_scheme.dark?}"
puts "Is Light?   #{dark_scheme.light?}"
puts

puts "--- Generating 256-Color Extended Palette ---"
# Generate standard ANSI 256 color palette derived from our base 16
standard_256 = dark_scheme.generate_256(harmonious: false)

# Generate a "harmonious" version which maps the color cube differently
harmonious_256 = dark_scheme.generate_256(harmonious: true)

puts "Standard ANSI color 200:   #{standard_256[200].hex}"
puts "Harmonious ANSI color 200: #{harmonious_256[200].hex}"
puts
puts "Notice how the generated colors differ slightly in harmonious mode to better match the theme's background and foreground properties."

