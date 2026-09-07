# src/theme/config/formats/wez_term.cr
module Theme::Config
  module Formats
    # WezTerm TOML themes (`[colors]` with `ansi` / `brights` arrays).
    module WezTerm
      extend self
      include TomlHelpers

      def parse(text : String, name = "") : Scheme
        colors = table(MiniTOML.parse(text), "colors") || raise ParseError.new("no [colors] table found")
        scheme = Scheme.new
        scheme.name = name

        scheme.foreground = hex(colors, "foreground")
        scheme.background = hex(colors, "background")
        scheme.cursor = hex(colors, "cursor_bg")
        scheme.cursor_text = hex(colors, "cursor_fg")
        scheme.selection_background = hex(colors, "selection_bg")
        scheme.selection_foreground = hex(colors, "selection_fg")

        colors["ansi"]?.as?(Array(String)).try &.each_with_index do |hex_val, i|
          scheme.set_ansi(i, Color.parse(hex_val)) if i < 8
        end
        colors["brights"]?.as?(Array(String)).try &.each_with_index do |hex_val, i|
          scheme.set_ansi(i + 8, Color.parse(hex_val)) if i < 8
        end
        scheme
      end
    end
  end
end
