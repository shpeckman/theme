# examples/01_color_and_contrast.cr
require "./example_helper"

# Parse colors from hex strings
bg = Theme::Color.parse("#282C34")
fg = Theme::Color.parse("#ABB2BF")
accent = Theme::Color.parse("#E06C75")

puts "--- Color Parsing & Metrics ---"
puts "Background: #{bg.hex}"
puts "Foreground: #{fg.hex}"
puts "Accent:     #{accent.hex}"
puts

# Calculate luminance
puts "Background Luminance: #{bg.luminance.round(4)}"
puts "Background Perceived: #{bg.perceived_luminance.round(4)}"
puts

# Calculate WCAG Contrast Ratios
fg_contrast = bg.contrast(fg)
accent_contrast = bg.contrast(accent)

puts "Contrast (BG to FG):     #{fg_contrast.round(2)}:1"
if fg_contrast >= 4.5
  puts "  -> Passes WCAG AA for normal text"
else
  puts "  -> Fails WCAG AA for normal text"
end

puts "Contrast (BG to Accent): #{accent_contrast.round(2)}:1"
if accent_contrast >= 4.5
  puts "  -> Passes WCAG AA for normal text"
else
  puts "  -> Fails WCAG AA for normal text"
end

