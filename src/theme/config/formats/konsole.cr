# src/theme/config/formats/konsole.cr
module Theme::Config
  module Formats
    # Konsole `.colorscheme` files (INI with `Color=r,g,b` triplets).
    module Konsole
      extend self

      def parse(text : String, name = "") : Scheme
        ini    = MiniINI.parse(text)
        scheme = Scheme.new
        scheme.name = ini.dig?("General", "Description") || name

        ini.each do |section, entries|
          color = entries["Color"]?.try { |v| rgb_from_triplet(v) } || next
          case section
          when "Background"                   then scheme.background = color
          when "Foreground"                   then scheme.foreground = color
          when .matches?(/^Color\d+$/)        then scheme.set_ansi(section[5..].to_i, color)
          when .matches?(/^Color\d+Intense$/) then scheme.set_ansi(section[5..-8].to_i + 8, color)
          end
        end
        scheme
      end

      private def rgb_from_triplet(s : String) : Color?
        parts = s.split(',')
        return unless parts.size == 3
        rgb = parts.map { |p| p.strip.to_i? || return }
        Color.new(rgb[0].clamp(0, 255).to_u8, rgb[1].clamp(0, 255).to_u8, rgb[2].clamp(0, 255).to_u8)
      end
    end
  end
end
