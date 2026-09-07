# src/theme/config/formats/terminal_app.cr
module Theme::Config
  module Formats
    # macOS Terminal.app `.terminal` files (XML or binary plist, with colors
    # stored as data blobs containing space-separated P3 float components).
    module TerminalApp
      extend self

      ANSI_KEYS = %w[Black Red Green Yellow Blue Magenta Cyan White]

      def parse(text : String, name = "") : Scheme
        parse(text.to_slice, name)
      end

      def parse(bytes : Bytes, name = "") : Scheme
        data   = Plist.parse(bytes).as(Hash(String, PlistValue))
        scheme = Scheme.new
        scheme.name = name

        data.each do |key, value|
          next unless value.is_a?(Bytes)
          color = rgb_from_blob(value) || next

          case key
          when .starts_with?("ANSI")
            body = key[4..-6]
            if body.starts_with?("Bright")
              if idx = ANSI_KEYS.index(body[6..])
                scheme.set_ansi(idx + 8, color)
              end
            elsif idx = ANSI_KEYS.index(body)
              scheme.set_ansi(idx, color)
            end
          when "TextColor"       then scheme.foreground = color
          when "BackgroundColor" then scheme.background = color
          when "CursorColor"     then scheme.cursor = color
          when "SelectionColor"  then scheme.selection_background = color
          end
        end
        scheme
      end

      private def rgb_from_blob(blob : Bytes) : Color?
        text = Plist.scrub_utf8(blob).lstrip
        if text.starts_with?("bplist00") || text.starts_with?('<')
          # Modern Terminal.app stores colors as NSKeyedArchiver plists;
          # dig the float components out of the nested structure.
          find_color(Plist.parse(blob))
        else
          # Old-style blob: the raw space-separated float string itself.
          parse_float_string(text)
        end
      end

      private def find_color(value : PlistValue) : Color?
        case value
        when Bytes
          parse_float_string(Plist.scrub_utf8(value))
        when Array(PlistValue)
          value.each do |e|
            color = find_color(e)
            return color if color
          end
        when Hash(String, PlistValue)
          value.each_value do |e|
            color = find_color(e)
            return color if color
          end
        end
      end

      private def parse_float_string(s : String) : Color?
        parts = s.gsub('\u0000', ' ').split(' ', remove_empty: true)
        return if parts.empty?
        floats = parts.map { |p| p.to_f64? || return }
        case floats.size
        when 2
          gray = floats[0]
          Color.from_p3(gray, gray, gray)
        when .>= 3
          Color.from_p3(floats[0], floats[1], floats[2])
        end
      end
    end
  end
end
