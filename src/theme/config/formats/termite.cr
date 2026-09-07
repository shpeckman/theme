# src/theme/config/formats/termite.cr
module Theme::Config
  module Formats
    # Termite `[colors]` config sections.
    module Termite
      extend self

      def parse(text : String, name = "") : Scheme
        ini    = MiniINI.parse(text)
        colors = ini["colors"]? || raise ParseError.new("no [colors] section found")
        scheme = Scheme.new
        scheme.name = name

        colors.each do |key, value|
          next if value.empty?
          case key
          when "foreground"        then scheme.foreground = Color.parse(value)
          when "background"        then scheme.background = Color.parse(value)
          when "cursor"            then scheme.cursor = Color.parse(value)
          when "cursor_foreground" then scheme.cursor_text = Color.parse(value)
          when .matches?(/^color\d+$/)
            scheme.set_ansi(key[5..].to_i, Color.parse(value))
          end
        end
        scheme
      end
    end
  end
end
