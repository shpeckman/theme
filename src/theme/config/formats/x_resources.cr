# src/theme/config/formats/x_resources.cr
module Theme::Config
  module Formats
    # XResources themes (`*.colorN: #rrggbb` lines, `!` comments).
    module XResources
      extend self

      LINE = /^\*\.(\w+):\s*(\S+)/

      def parse(text : String, name = "") : Scheme
        scheme = Scheme.new
        scheme.name = name

        text.each_line do |line|
          next if line.starts_with?('!')
          if m = line.match(LINE)
            key, value = m[1], m[2]
            case key
            when "foreground"  then scheme.foreground = Color.parse(value)
            when "background"  then scheme.background = Color.parse(value)
            when "cursorColor" then scheme.cursor = Color.parse(value)
            when .matches?(/^color\d+$/)
              scheme.set_ansi(key[5..].to_i, Color.parse(value))
            end
          end
        end
        scheme
      end
    end
  end
end
