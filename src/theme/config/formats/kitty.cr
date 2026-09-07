# src/theme/config/formats/kitty.cr
module Theme::Config
  module Formats
    # Kitty `.conf` themes (whitespace-separated `key value` lines).
    module Kitty
      extend self

      def parse(text : String, name = "") : Scheme
        scheme = Scheme.new
        scheme.name = name

        text.each_line do |line|
          line = line.strip
          next if line.empty? || line.starts_with?('#')
          key, _, value = line.partition(/\s+/)
          next if value.empty?

          case key
          when "foreground"           then scheme.foreground = Color.parse(value)
          when "background"           then scheme.background = Color.parse(value)
          when "cursor"               then scheme.cursor = Color.parse(value)
          when "cursor_text_color"    then scheme.cursor_text = Color.parse(value)
          when "selection_foreground" then scheme.selection_foreground = Color.parse(value)
          when "selection_background" then scheme.selection_background = Color.parse(value)
          when .matches?(/^color\d+$/)
            scheme.set_ansi(key[5..].to_i, Color.parse(value))
          end
        end
        scheme
      end
    end
  end
end
