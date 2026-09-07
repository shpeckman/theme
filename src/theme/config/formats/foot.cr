# src/theme/config/formats/foot.cr
module Theme::Config
  module Formats
    # foot `foot.ini` themes (`[colors]` section, hex values without `#`).
    module Foot
      extend self

      def parse(text : String, name = "") : Scheme
        ini = MiniINI.parse(text)
        colors = ini["colors-dark"]? || ini["colors"]? || ini["colors-light"]? ||
                 raise ParseError.new("no [colors] section found")
        scheme = Scheme.new
        scheme.name = name

        colors.each do |key, value|
          case key
          when "foreground"           then scheme.foreground = Color.parse(value)
          when "background"           then scheme.background = Color.parse(value)
          when "selection-foreground" then scheme.selection_foreground = Color.parse(value)
          when "selection-background" then scheme.selection_background = Color.parse(value)
          when "cursor"
            parts = value.split
            scheme.cursor_text = Color.parse(parts[0]) if parts[0]?
            scheme.cursor = Color.parse(parts[1]) if parts[1]?
          when .matches?(/^(regular|bright)\d$/)
            next if value.empty?
            color = Color.parse(value)
            slot  = key[-1].to_i
            scheme.set_ansi(slot + (key.starts_with?("bright") ? 8 : 0), color)
          end
        end
        scheme
      end
    end
  end
end
