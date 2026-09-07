# examples/04_theme_fading.cr
require "./example_helper"

# Define a dark theme
dark_theme = Theme::Scheme.new(
  name: "Dark Mode",
  palette: generate_mock_palette(Theme::Color.parse("#101010")),
  background: Theme::Color.parse("#1E1E1E"),
  foreground: Theme::Color.parse("#D4D4D4")
)

# Define a light theme
light_theme = Theme::Scheme.new(
  name: "Light Mode",
  palette: generate_mock_palette(Theme::Color.parse("#E0E0E0")),
  background: Theme::Color.parse("#FAFAFA"),
  foreground: Theme::Color.parse("#333333")
)

steps = 5

puts "--- Scheme Cross-fading ---"
puts "Fading from #{dark_theme.name} to #{light_theme.name} over #{steps} frames:"
puts

# Fade between the two themes
# This interpolates the entire 16-color palette AND all UI colors (bg, fg, cursor, etc.)
transition_frames = dark_theme.fade_to(light_theme, steps)

transition_frames.each_with_index do |frame, index|
  bg = frame.background_hex
  fg = frame.foreground_hex

  # Grabbing a couple palette colors to show they interpolate too
  c1 = frame[0].hex
  c2 = frame[8].hex

  puts "Frame #{index + 1}: BG #{bg} | FG #{fg} | Palette[0] #{c1} | Palette[8] #{c2}"
end
