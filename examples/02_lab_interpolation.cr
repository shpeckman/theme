# examples/02_lab_interpolation.cr
require "./example_helper"

# CIELAB interpolation creates much more perceptually uniform gradients
# compared to standard RGB interpolation.

color1 = Theme::Color.parse("#FF0000") # Red
color2 = Theme::Color.parse("#0000FF") # Blue

lab1 = Theme::Lab.from_color(color1)
lab2 = Theme::Lab.from_color(color2)

steps = 7

puts "--- CIELAB Perceptual Interpolation ---"
puts "Fading from #{color1.hex} to #{color2.hex} in #{steps} steps:"
puts

steps.times do |i|
  # Calculate interpolation factor from 0.0 to 1.0
  t = i / (steps - 1).to_f64
  
  # Interpolate in Lab color space, then convert back to RGB
  blended_lab = lab1.lerp(lab2, t)
  blended_color = blended_lab.to_color
  
  puts "Step #{i + 1} (t=#{t.round(2)}): #{blended_color.hex}"
end

