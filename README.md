# theme

A zero-dependency Crystal shard for working with terminal color schemes.

- Parse theme/config files from **16 terminal emulators** (iTerm2, Kitty, Alacritty, Windows Terminal, …)
- Work with colors: hex parsing, WCAG luminance & contrast, Display P3 → sRGB conversion
- Interpolate entire schemes in perceptually uniform **CIELAB** space
- Generate full **256-color palettes** from a 16-color scheme
- JSON & YAML serialization throughout

Requires **Crystal ≥ 1.21.0**.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  theme:
    github: shpeckman/theme
```

Then:

```sh
shards install
```

```crystal
require "theme"
```

## Usage

### Colors

```crystal
color = Theme::Color.parse("#E06C75")        # raises Theme::ParseError on bad input
color = Theme::Color.parse?("#e06c75")       # nil-safe variant
color = Theme::Color.from_floats(0.8, 0.2, 0.3) # sRGB components in 0.0–1.0
color = Theme::Color.from_p3(1.0, 0.0, 0.0)     # Display P3 → sRGB

color.hex                 # => "#e06c75"
color.luminance           # WCAG relative luminance (0.0–1.0)
color.perceived_luminance # simple weighted brightness (0.0–1.0)

bg = Theme::Color.parse("#282C34")
bg.contrast(color)        # => 4.36 (WCAG contrast ratio)
```

### Schemes

A `Theme::Scheme` is a validated 16-color palette plus optional foreground,
background, cursor and selection colors:

```crystal
scheme = Theme::Scheme.from_hex(
  palette: %w[#1e2127 #e06c75 #98c379 #d19a66 #61afef #c678dd #56b6c2 #abb2bf
              #5c6370 #e06c75 #98c379 #d19a66 #61afef #c678dd #56b6c2 #ffffff],
  name: "One Dark",
  foreground: "#abb2bf",
  background: "#282c34",
)

scheme.dark?        # => true
scheme.palette[1]   # => Theme::Color(#e06c75)
scheme.to_json      # serialize (YAML too)
scheme.fade_to(other_scheme, 8) # CIELAB-interpolated gradient of schemes
scheme.generate_256             # StaticArray(Theme::Color, 256)
scheme.generate_256(harmonious: true)
```

### Parsing terminal config files

`Theme::Config` reads theme files from 16 different terminal emulators. The
format is auto-detected from the file extension, with content sniffing as a
fallback:

```crystal
config = Theme::Config.parse_file("themes/Dracula.itermcolors")
config.name       # => "Dracula" (file basename, or a name found inside the file)
config.complete?  # => true — all 16 palette slots plus fg/bg were found

scheme = config.to_scheme   # => Theme::Scheme (raises Theme::ParseError if incomplete)
scheme = config.to_scheme?  # => Theme::Scheme? (nil if incomplete)
```

Override detection or parse a string directly:

```crystal
config = Theme::Config.parse_file("theme.txt", format: Theme::Config::Format::Kitty)
config = Theme::Config::Format::Alacritty.parse(toml_text, name: "mine")
```

#### Supported formats

| Format             | `Format::` member | Typical file                               | Detection                   |
|--------------------|-------------------|--------------------------------------------|-----------------------------|
| iTerm2             | `ITermColors`     | `*.itermcolors`                            | extension                   |
| macOS Terminal.app | `TerminalApp`     | `*.terminal` (XML or binary plist)         | extension                   |
| Alacritty          | `Alacritty`       | `*.toml`                                   | content (`[colors.bright]`) |
| WezTerm            | `WezTerm`         | `*.toml`                                   | content (`ansi` key)        |
| Rio                | `Rio`             | `*.toml`                                   | TOML fallback               |
| Windows Terminal   | `WindowsTerminal` | `*.json`                                   | content                     |
| VSCode             | `VSCode`          | `*.json` (`workbench.colorCustomizations`) | content                     |
| Konsole            | `Konsole`         | `*.colorscheme`                            | extension                   |
| foot               | `Foot`            | `*.ini`                                    | extension                   |
| Termite            | `Termite`         | `config`                                   | content (`[colors]` header) |
| Xfce4 Terminal     | `Xfce4`           | `*.theme`                                  | extension                   |
| Terminator         | `Terminator`      | `*.config`                                 | extension                   |
| Kitty              | `Kitty`           | `*.conf`                                   | extension                   |
| Ghostty            | `Ghostty`         | `config`                                   | content (`palette = 0=`)    |
| XResources         | `XResources`      | `*.xrdb`                                   | extension or content        |
| Generic YAML       | `YamlSource`      | `*.yml` / `*.yaml`                         | extension                   |

### Working with partial configs

Parsing produces a `Theme::Config::Scheme`: a lenient, mutable accumulator in
which every slot is optional, because real-world config files are often
incomplete:

```crystal
config = Theme::Config::Format::Kitty.parse("foreground #d0d0d0\nbackground #121212\n")

config.complete?    # => false (no palette)
config.to_scheme?   # => nil
config.foreground   # => Theme::Color(#d0d0d0)
config.ansi         # => Array(Theme::Color?) of 16 slots
```

`set_ansi` / `set_ansi_by_name` accept indexes (0–15) and names
(`"red"`, `"bright_blue"`, `"light_black"`; `"purple"` aliases `"magenta"`).
Indexes above 15 (e.g. Kitty's `color16`+ or Ghostty's extended palette) are
parsed but dropped — the ANSI model is 16 colors; use `Theme::Scheme#generate_256`
if you need the extended range.

`Theme::Config::Scheme` also round-trips through JSON and YAML.

## Notes & limitations

- Crystal does not expand `~` in paths — use
  `File.expand_path("~/.config/kitty/kitty.conf")`.
- The TOML reader is intentionally minimal: single-line values only (no
  multi-line arrays or inline tables). Typical theme files are fine.
- XResources parsing matches `*.colorN:`-style lines only.
- Invalid color values raise `Theme::ParseError`.

## Development

```sh
shards install
crystal spec             # run the test suite
```

## Contributing

Bug reports and pull requests are welcome.

## Authors

- shpeckman <geelenrobin@proton.me>

## License

MIT
