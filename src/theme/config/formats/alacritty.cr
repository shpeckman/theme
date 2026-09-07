# src/theme/config/formats/alacritty.cr
module Theme::Config
  module Formats
    # Alacritty TOML themes (`[colors.primary]`, `[colors.normal]`, ...).
    module Alacritty
      extend self
      include TomlHelpers

      def parse(text : String, name = "") : Scheme
        colors = table(MiniTOML.parse(text), "colors") || raise ParseError.new("no [colors] table found")
        scheme = Scheme.new
        scheme.name = name

        if primary = table(colors, "primary")
          scheme.background = hex(primary, "background")
          scheme.foreground = hex(primary, "foreground")
        end
        if normal = table(colors, "normal")
          Scheme::ANSI_NAMES.each { |n| hex(normal, n).try { |c| scheme.set_ansi_by_name(n, c) } }
        end
        if bright = table(colors, "bright")
          Scheme::ANSI_NAMES.each { |n| hex(bright, n).try { |c| scheme.set_ansi_by_name("bright_#{n}", c) } }
        end
        if cursor = table(colors, "cursor")
          scheme.cursor = hex(cursor, "cursor")
          scheme.cursor_text = hex(cursor, "text")
        end
        if sel = table(colors, "selection")
          scheme.selection_background = hex(sel, "background")
          scheme.selection_foreground = hex(sel, "text")
        end
        scheme
      end
    end
  end
end
