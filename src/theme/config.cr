# src/theme/config.cr
require "json"
require "yaml"
require "xml"
require "base64"

require "./config/scheme"
require "./config/mini_toml"
require "./config/mini_ini"
require "./config/plist"
require "./config/toml_helpers"
require "./config/formats/*"

# Parsers for terminal emulator theme/config file formats.
#
# Each parser produces a `Theme::Config::Scheme` — a mutable accumulator with
# optional slots — which can be converted into a validated `Theme::Scheme`
# via `#to_scheme` once a full palette is present.
#
# ```
# config = Theme::Config.parse_file("~/.config/kitty/kitty.conf")
# scheme = config.to_scheme # => Theme::Scheme
# scheme.dark?              # => true
# ```
module Theme::Config
  # The supported terminal config formats.
  enum Format
    ITermColors
    TerminalApp
    Alacritty
    WezTerm
    Rio
    WindowsTerminal
    VSCode
    Konsole
    Foot
    Termite
    Xfce4
    Terminator
    Kitty
    Ghostty
    XResources
    YamlSource

    # Parses *text* in this format into a `Theme::Config::Scheme`.
    def parse(text : String, name = "") : Scheme
      case self
      in .i_term_colors?    then Formats::ITermColors.parse(text, name)
      in .terminal_app?     then Formats::TerminalApp.parse(text, name)
      in .alacritty?        then Formats::Alacritty.parse(text, name)
      in .wez_term?         then Formats::WezTerm.parse(text, name)
      in .rio?              then Formats::Rio.parse(text, name)
      in .windows_terminal? then Formats::WindowsTerminal.parse(text, name)
      in .vs_code?          then Formats::VSCode.parse(text, name)
      in .konsole?          then Formats::Konsole.parse(text, name)
      in .foot?             then Formats::Foot.parse(text, name)
      in .termite?          then Formats::Termite.parse(text, name)
      in .xfce4?            then Formats::Xfce4.parse(text, name)
      in .terminator?       then Formats::Terminator.parse(text, name)
      in .kitty?            then Formats::Kitty.parse(text, name)
      in .ghostty?          then Formats::Ghostty.parse(text, name)
      in .x_resources?      then Formats::XResources.parse(text, name)
      in .yaml_source?      then Formats::YamlSource.parse(text, name)
      end
    end
  end

  # Guesses the format of *path* from its extension, falling back to content
  # sniffing for ambiguous or missing extensions. *text*, when given, avoids
  # re-reading the file for content sniffing.
  #
  # Raises `Theme::ParseError` when the format cannot be determined.
  def self.detect_format(path : String, text : String? = nil) : Format
    case File.extname(path).downcase
    when ".itermcolors"  then Format::ITermColors
    when ".terminal"     then Format::TerminalApp
    when ".colorscheme"  then Format::Konsole
    when ".theme"        then Format::Xfce4
    when ".config"       then Format::Terminator
    when ".conf"         then Format::Kitty
    when ".xrdb"         then Format::XResources
    when ".ini"          then Format::Foot
    when ".yml", ".yaml" then Format::YamlSource
    when ".json"
      (text || File.read(path)).includes?("workbench.colorCustomizations") ? Format::VSCode : Format::WindowsTerminal
    when ".toml"
      t = text || File.read(path)
      t.includes?("[colors.bright]") ? Format::Alacritty : t.includes?("ansi") ? Format::WezTerm : Format::Rio
    else
      t = (text || File.read(path))
      if t.includes?("palette = 0=")
        Format::Ghostty
      elsif t.lstrip.starts_with?("[colors]")
        Format::Termite
      elsif t.lstrip.starts_with?('!') || t.includes?("*.color")
        Format::XResources
      else
        raise ParseError.new("cannot detect format of #{path}; pass format explicitly")
      end
    end
  end

  # Parses the file at *path* into a `Theme::Config::Scheme`. The format is
  # auto-detected via `.detect_format` unless *format* is given. The scheme
  # name defaults to the file's basename (a format may override it with a
  # name found inside the file).
  def self.parse_file(path : String, format : Format? = nil) : Scheme
    text = File.read(path)
    format ||= detect_format(path, text)
    format.parse(text, File.basename(path, File.extname(path)))
  end
end
