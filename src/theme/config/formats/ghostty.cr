# src/theme/config/formats/ghostty.cr
module Theme::Config
  module Formats
    # Ghostty config themes (`key = value` lines, `palette = N=#rrggbb`).
    module Ghostty
      extend self

      def parse(text : String, name = "") : Scheme
        scheme = Scheme.new
        scheme.name = name

        text.each_line do |line|
          line = line.strip
          next if line.empty? || line.starts_with?('#')
          key, _, value = line.partition('=')
          key   = key.strip
          value = value.strip
          next if value.empty?

          case key
          when "foreground"           then scheme.foreground = Color.parse(value)
          when "background"           then scheme.background = Color.parse(value)
          when "cursor-color"         then scheme.cursor = Color.parse(value)
          when "cursor-text"          then scheme.cursor_text = Color.parse(value)
          when "selection-foreground" then scheme.selection_foreground = Color.parse(value)
          when "selection-background" then scheme.selection_background = Color.parse(value)
          when "palette"
            idx, _, hex_val = value.partition('=')
            scheme.set_ansi(idx.to_i, Color.parse(hex_val))
          end
        end
        scheme
      end
    end
  end
end
