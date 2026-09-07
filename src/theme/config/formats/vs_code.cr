# src/theme/config/formats/vs_code.cr
require "json"

module Theme::Config
  module Formats
    # VSCode settings JSON (`workbench.colorCustomizations` terminal keys).
    module VSCode
      extend self

      def parse(text : String, name = "") : Scheme
        doc    = JSON.parse(text)
        colors = doc.dig?("workbench.colorCustomizations") || raise ParseError.new("no workbench.colorCustomizations key")
        scheme = Scheme.new
        scheme.name = name

        colors.as_h.each do |key, value|
          next unless value.raw.is_a?(String)
          color = Color.parse?(value.as_s) || next
          case key
          when "terminal.foreground"          then scheme.foreground = color
          when "terminal.background"          then scheme.background = color
          when "terminal.selectionBackground" then scheme.selection_background = color
          when "terminalCursor.foreground"    then scheme.cursor = color
          when "terminalCursor.background"    then scheme.cursor_text = color
          when .starts_with?("terminal.ansi")
            slot = key.lchop("terminal.ansi")
            scheme.set_ansi_by_name(slot.underscore, color)
          end
        end
        scheme
      end
    end
  end
end
