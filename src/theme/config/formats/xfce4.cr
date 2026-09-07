# src/theme/config/formats/xfce4.cr
module Theme::Config
  module Formats
    # Xfce4 Terminal `.theme` files (`[Scheme]` section, `;`-separated palette).
    module Xfce4
      extend self

      def parse(text : String, name = "") : Scheme
        ini        = MiniINI.parse(text)
        scheme_ini = ini["Scheme"]? || raise ParseError.new("no [Scheme] section found")
        scheme     = Scheme.new
        scheme.name = scheme_ini["Name"]? || name

        scheme_ini["ColorForeground"]?.try { |v| scheme.foreground = Color.parse(v) }
        scheme_ini["ColorBackground"]?.try { |v| scheme.background = Color.parse(v) }
        scheme_ini["ColorCursor"]?.try { |v| scheme.cursor = Color.parse(v) }
        scheme_ini["ColorPalette"]?.try do |palette|
          palette.split(';').each_with_index do |hex_val, i|
            scheme.set_ansi(i, Color.parse(hex_val))
          end
        end
        scheme
      end
    end
  end
end
