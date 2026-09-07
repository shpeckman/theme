# src/theme/config/scheme.cr
require "json"
require "yaml"

module Theme::Config
  # Mutable accumulator produced by terminal config parsers.
  #
  # Unlike `Theme::Scheme`, every slot is optional and the ANSI palette may be
  # partially filled, reflecting the reality of terminal config files. Call
  # `#complete?` to check whether a full palette plus foreground/background
  # were found, and `#to_scheme` / `#to_scheme?` to convert into a validated
  # `Theme::Scheme`.
  class Scheme
    include JSON::Serializable
    include YAML::Serializable

    property name = ""
    property foreground           : Color?
    property background           : Color?
    property cursor               : Color?
    property cursor_text          : Color?
    property selection_foreground : Color?
    property selection_background : Color?

    property ansi = Array(Color?).new(16) { nil }

    def initialize
    end

    ANSI_NAMES = %w[black red green yellow blue magenta cyan white]

    # Sets palette slot *index* (0-15); out-of-range indexes are ignored.
    def set_ansi(index : Int, color : Color)
      @ansi[index] = color if 0 <= index < 16
    end

    # Sets a palette slot by color name, e.g. `"red"`, `"bright_blue"` or
    # `"light_black"`. `"purple"` is accepted as an alias for `"magenta"`.
    # Unknown names are ignored.
    def set_ansi_by_name(slot : String, color : Color)
      name   = slot.downcase
      bright = name.starts_with?("bright_") || name.starts_with?("light_")
      base   = bright ? name.split('_', 2)[1] : name
      base   = "magenta" if base == "purple"
      if idx = ANSI_NAMES.index(base)
        @ansi[idx + (bright ? 8 : 0)] = color
      end
    end

    # True when all 16 palette slots plus foreground and background are set.
    def complete? : Bool
      @ansi.all? && !@foreground.nil? && !@background.nil?
    end

    # Converts to a validated `Theme::Scheme`.
    #
    # Raises `Theme::ParseError` unless `#complete?`.
    def to_scheme : Theme::Scheme
      to_scheme? || raise ParseError.new("incomplete color scheme#{@name.presence.try { |n| " (#{n})" }}: a full 16-color palette plus foreground and background are required")
    end

    # Converts to a validated `Theme::Scheme`, or `nil` unless `#complete?`.
    def to_scheme? : Theme::Scheme?
      return nil unless complete?

      palette = uninitialized StaticArray(Color, 16)
      16.times { |i| palette[i] = @ansi[i].not_nil! }

      Theme::Scheme.new(
        palette: palette,
        name: @name.presence,
        foreground: @foreground,
        background: @background,
        cursor: @cursor,
        cursor_text: @cursor_text,
        selection_foreground: @selection_foreground,
        selection_background: @selection_background
      )
    end
  end
end
