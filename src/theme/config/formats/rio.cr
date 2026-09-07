# src/theme/config/formats/rio.cr
module Theme::Config
  module Formats
    # Rio TOML themes (`[colors]` with flat named entries).
    module Rio
      extend self
      include TomlHelpers

      def parse(text : String, name = "") : Scheme
        colors = table(MiniTOML.parse(text), "colors") || raise ParseError.new("no [colors] table found")
        scheme = Scheme.new
        scheme.name = name

        scheme.foreground = hex(colors, "foreground")
        scheme.background = hex(colors, "background")
        scheme.cursor = hex(colors, "cursor")
        scheme.selection_background = hex(colors, "selection-background")
        scheme.selection_foreground = hex(colors, "selection-foreground")

        colors.each do |key, value|
          next unless value.is_a?(String)
          scheme.set_ansi_by_name(key, Color.parse(value))
        end
        scheme
      end
    end
  end
end
