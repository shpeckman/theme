# src/theme/config/formats/windows_terminal.cr
require "json"

module Theme::Config
  module Formats
    # Windows Terminal scheme JSON (a single scheme object with camelCase keys).
    module WindowsTerminal
      extend self

      def parse(text : String, name = "") : Scheme
        doc    = JSON.parse(text)
        scheme = Scheme.new
        scheme.name = doc["name"]?.try(&.as_s) || name

        doc.as_h.each do |key, value|
          next unless value.raw.is_a?(String)
          color = parse_hex(value.as_s) || next
          case key
          when "background"          then scheme.background = color
          when "foreground"          then scheme.foreground = color
          when "cursorColor"         then scheme.cursor = color
          when "selectionBackground" then scheme.selection_background = color
          else
            scheme.set_ansi_by_name(key.underscore, color)
          end
        end
        scheme
      end

      private def parse_hex(s : String) : Color?
        s = s.strip
        return unless s.matches?(/^#?[0-9a-fA-F]{6}$/)
        Color.parse(s)
      end
    end
  end
end
