# src/theme/config/formats/iterm_colors.cr
module Theme::Config
  module Formats
    # iTerm2 `.itermcolors` files (XML or binary plist).
    module ITermColors
      extend self

      def parse(text : String, name = "") : Scheme
        parse(text.to_slice, name)
      end

      def parse(bytes : Bytes, name = "") : Scheme
        data   = Plist.parse(bytes).as(Hash(String, PlistValue))
        scheme = Scheme.new
        scheme.name = name

        data.each do |key, value|
          next if key.ends_with?("(Dark)") || key.ends_with?("(Light)")
          next unless value.is_a?(Hash)
          color = rgb_from_components(value)

          case key
          when .matches?(/^Ansi \d+ Color$/) then scheme.set_ansi(key[5..-7].to_i, color)
          when "Foreground Color"            then scheme.foreground = color
          when "Background Color"            then scheme.background = color
          when "Cursor Color"                then scheme.cursor = color
          when "Cursor Text Color"           then scheme.cursor_text = color
          when "Selection Color"             then scheme.selection_background = color
          when "Selected Text Color"         then scheme.selection_foreground = color
          end
        end
        scheme
      end

      private def rgb_from_components(dict : Hash(String, PlistValue)) : Color
        r = component(dict, "Red Component")
        g = component(dict, "Green Component")
        b = component(dict, "Blue Component")
        dict["Color Space"]? == "P3" ? Color.from_p3(r, g, b) : Color.from_floats(r, g, b)
      end

      private def component(dict : Hash(String, PlistValue), key : String) : Float64
        case v = dict[key]?
        when Float64 then v
        when Int64   then v.to_f64
        else              0.0
        end
      end
    end
  end
end
