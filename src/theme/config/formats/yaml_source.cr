# src/theme/config/formats/yaml_source.cr
require "yaml"

module Theme::Config
  module Formats
    # Generic YAML themes (`foreground:`/`background:`/`cursor:` keys plus
    # `color_01`..`color_16` palette entries).
    module YamlSource
      extend self

      def parse(text : String, name = "") : Scheme
        doc    = YAML.parse(text)
        scheme = Scheme.new
        scheme.name = doc["name"]?.try(&.as_s?) || name

        doc["foreground"]?.try { |v| v.as_s?.try { |s| scheme.foreground = Color.parse(s) } }
        doc["background"]?.try { |v| v.as_s?.try { |s| scheme.background = Color.parse(s) } }
        doc["cursor"]?.try { |v| v.as_s?.try { |s| scheme.cursor = Color.parse(s) } }
        doc["cursor_text"]?.try { |v| v.as_s?.try { |s| scheme.cursor_text = Color.parse(s) } }

        (1..16).each do |i|
          if node = doc["color_%02d" % i]?
            if s = node.as_s?
              scheme.set_ansi(i - 1, Color.parse(s))
            end
          end
        end
        scheme
      end
    end
  end
end
