# src/theme/config/formats/terminator.cr
module Theme::Config
  module Formats
    # Terminator profile snippets (`[[name]]` sections are flattened to plain
    # INI sections; palette is a `:`-separated string).
    module Terminator
      extend self

      def parse(text : String, name = "") : Scheme
        ini = MiniINI.parse(text.gsub(/\[\[([^\]]+)\]\]/, "[\\1]"))
        raise ParseError.new("no [section] found") if ini.empty?
        section, entries = ini.first
        scheme = Scheme.new
        scheme.name = section.presence || name

        entries["palette"]?.try do |palette|
          palette.strip.strip('"').split(':').each_with_index do |hex_val, i|
            scheme.set_ansi(i, Color.parse(hex_val))
          end
        end
        entries["background_color"]?.try { |v| scheme.background = Color.parse(v.strip('"')) }
        entries["foreground_color"]?.try { |v| scheme.foreground = Color.parse(v.strip('"')) }
        entries["cursor_color"]?.try { |v| scheme.cursor = Color.parse(v.strip('"')) }
        scheme
      end
    end
  end
end
