# spec/config_spec.cr
require "./spec_helper"

describe Theme::Config do
  fixtures = File.join(__DIR__, "fixtures", "config")

  describe ".parse_file" do
    it "parses Kitty" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "kitty.conf"))

      scheme.name.should eq "kitty"
      scheme.foreground.should eq Theme::Color.new(0xd0, 0xd0, 0xd0)
      scheme.background.should eq Theme::Color.new(0x12, 0x12, 0x12)
      scheme.cursor.should eq Theme::Color.new(0xff, 0xcc, 0x00)
      scheme.cursor_text.should eq Theme::Color.new(0x10, 0x10, 0x10)
      scheme.selection_foreground.should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.selection_background.should eq Theme::Color.new(0x33, 0x55, 0x77)
      scheme.ansi[1].should eq Theme::Color.new(0xd7, 0x26, 0x3d)
      scheme.ansi[15].should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.complete?.should be_true
    end

    it "ignores Kitty palette indexes above 15" do
      # the kitty.conf fixture contains a `color16` line; the palette stays at 16
      scheme = Theme::Config.parse_file(File.join(fixtures, "kitty.conf"))
      scheme.ansi.size.should eq 16
    end

    it "parses Ghostty" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "ghostty"))

      scheme.name.should eq "ghostty"
      scheme.foreground.should eq Theme::Color.new(0xdd, 0xee, 0xdd)
      scheme.background.should eq Theme::Color.new(0x10, 0x10, 0x10)
      scheme.cursor.should eq Theme::Color.new(0x00, 0xff, 0x00)
      scheme.cursor_text.should eq Theme::Color.new(0x00, 0x00, 0x00)
      scheme.selection_background.should eq Theme::Color.new(0x44, 0x44, 0x44)
      scheme.ansi[3].should eq Theme::Color.new(0xf7, 0xd1, 0x54)
      scheme.ansi[14].should eq Theme::Color.new(0x4c, 0xc9, 0xc0)
      scheme.complete?.should be_true
    end

    it "parses Termite" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "termite_config"))

      scheme.name.should eq "termite_config"
      scheme.foreground.should eq Theme::Color.new(0xc0, 0xc0, 0xc0)
      scheme.background.should eq Theme::Color.new(0x1b, 0x1b, 0x1b)
      scheme.cursor.should eq Theme::Color.new(0xff, 0xaa, 0x00)
      scheme.cursor_text.should eq Theme::Color.new(0x00, 0x00, 0x00)
      scheme.ansi[10].should eq Theme::Color.new(0xa0, 0xc4, 0x68)
      scheme.complete?.should be_true
    end

    it "parses XResources" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "xresources.xrdb"))

      scheme.name.should eq "xresources"
      scheme.foreground.should eq Theme::Color.new(0xc5, 0xc8, 0xc6)
      scheme.background.should eq Theme::Color.new(0x1d, 0x1f, 0x21)
      scheme.cursor.should eq Theme::Color.new(0xc5, 0xc8, 0xc6)
      scheme.ansi[12].should eq Theme::Color.new(0x81, 0xa2, 0xbe)
      scheme.complete?.should be_true
    end

    it "parses Alacritty" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "alacritty.toml"))

      scheme.name.should eq "alacritty"
      scheme.background.should eq Theme::Color.new(0x28, 0x2c, 0x34)
      scheme.foreground.should eq Theme::Color.new(0xab, 0xb2, 0xbf)
      scheme.ansi[0].should eq Theme::Color.new(0x1e, 0x21, 0x27)
      scheme.ansi[1].should eq Theme::Color.new(0xe0, 0x6c, 0x75)
      scheme.ansi[8].should eq Theme::Color.new(0x5c, 0x63, 0x70)
      scheme.ansi[15].should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.cursor.should eq Theme::Color.new(0x52, 0x8b, 0xff)
      scheme.cursor_text.should eq Theme::Color.new(0x10, 0x10, 0x10)
      scheme.selection_background.should eq Theme::Color.new(0x3e, 0x44, 0x51)
      scheme.selection_foreground.should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.complete?.should be_true
    end

    it "parses WezTerm" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "wezterm.toml"))

      scheme.name.should eq "wezterm"
      scheme.foreground.should eq Theme::Color.new(0xc8, 0xc8, 0xc8)
      scheme.background.should eq Theme::Color.new(0x20, 0x20, 0x20)
      scheme.cursor.should eq Theme::Color.new(0x00, 0xff, 0x00)
      scheme.cursor_text.should eq Theme::Color.new(0x00, 0x00, 0x00)
      scheme.selection_background.should eq Theme::Color.new(0x33, 0x44, 0x55)
      scheme.selection_foreground.should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.ansi[2].should eq Theme::Color.new(0x88, 0xb0, 0x4b)
      scheme.ansi[9].should eq Theme::Color.new(0xe2, 0x4a, 0x63)
      scheme.ansi[15].should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.complete?.should be_true
    end

    it "parses Rio" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "rio.toml"))

      scheme.name.should eq "rio"
      scheme.foreground.should eq Theme::Color.new(0xea, 0xea, 0xea)
      scheme.background.should eq Theme::Color.new(0x0f, 0x0f, 0x0f)
      scheme.cursor.should eq Theme::Color.new(0xff, 0x88, 0x00)
      scheme.selection_background.should eq Theme::Color.new(0x3a, 0x3a, 0x3a)
      scheme.ansi[1].should eq Theme::Color.new(0xd7, 0x26, 0x3d)
      scheme.ansi[9].should eq Theme::Color.new(0xe2, 0x4a, 0x63) # light_red
      scheme.complete?.should be_true
    end

    it "parses Windows Terminal" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "windows_terminal.json"))

      scheme.name.should eq "WT Test" # name key inside the file wins
      scheme.background.should eq Theme::Color.new(0x0c, 0x0c, 0x0c)
      scheme.foreground.should eq Theme::Color.new(0xcc, 0xcc, 0xcc)
      scheme.cursor.should eq Theme::Color.new(0x00, 0xff, 0x00)
      scheme.selection_background.should eq Theme::Color.new(0x26, 0x4f, 0x78)
      scheme.ansi[5].should eq Theme::Color.new(0x88, 0x17, 0x98)  # purple -> magenta
      scheme.ansi[8].should eq Theme::Color.new(0x76, 0x76, 0x76)  # brightBlack
      scheme.ansi[13].should eq Theme::Color.new(0xb4, 0x00, 0x9e) # brightPurple
      scheme.complete?.should be_true
    end

    it "parses VSCode" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "vscode.json"))

      scheme.name.should eq "vscode"
      scheme.foreground.should eq Theme::Color.new(0xd4, 0xd4, 0xd4)
      scheme.background.should eq Theme::Color.new(0x1e, 0x1e, 0x1e)
      scheme.cursor.should eq Theme::Color.new(0xae, 0xaf, 0xad)
      scheme.cursor_text.should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.selection_background.should eq Theme::Color.new(0x26, 0x4f, 0x78)
      scheme.ansi[1].should eq Theme::Color.new(0xcd, 0x31, 0x31)
      scheme.ansi[9].should eq Theme::Color.new(0xf1, 0x4c, 0x4c) # ansiBrightRed
      scheme.complete?.should be_true
    end

    it "parses Konsole" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "konsole.colorscheme"))

      scheme.name.should eq "Konsole Test" # from [General] Description
      scheme.background.should eq Theme::Color.new(15, 15, 15)
      scheme.foreground.should eq Theme::Color.new(200, 200, 200)
      scheme.ansi[1].should eq Theme::Color.new(215, 38, 61)
      scheme.ansi[9].should eq Theme::Color.new(226, 74, 99) # Color1Intense
      scheme.complete?.should be_true
    end

    it "parses foot" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "foot.ini"))

      scheme.name.should eq "foot"
      scheme.foreground.should eq Theme::Color.new(0xdc, 0xdc, 0xcc)
      scheme.background.should eq Theme::Color.new(0x11, 0x11, 0x11)
      scheme.cursor.should eq Theme::Color.new(0xdc, 0xdc, 0xcc)
      scheme.cursor_text.should eq Theme::Color.new(0x11, 0x11, 0x11)
      scheme.selection_foreground.should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.selection_background.should eq Theme::Color.new(0x33, 0x33, 0x44)
      scheme.ansi[1].should eq Theme::Color.new(0xd7, 0x26, 0x3d)
      scheme.ansi[9].should eq Theme::Color.new(0xe2, 0x4a, 0x63)
      scheme.complete?.should be_true
    end

    it "parses Xfce4" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "xfce4.theme"))

      scheme.name.should eq "Xfce Test" # from the Name key
      scheme.foreground.should eq Theme::Color.new(0xf8, 0xf8, 0xf2)
      scheme.background.should eq Theme::Color.new(0x28, 0x2a, 0x36)
      scheme.cursor.should eq Theme::Color.new(0xf8, 0xf8, 0xf2)
      scheme.ansi[0].should eq Theme::Color.new(0x21, 0x22, 0x2c)
      scheme.ansi[8].should eq Theme::Color.new(0x62, 0x72, 0xa4)
      scheme.ansi[15].should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.complete?.should be_true
    end

    it "parses Terminator" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "terminator.config"))

      scheme.name.should eq "Terminator Test" # from the [[section]] name
      scheme.background.should eq Theme::Color.new(0x1b, 0x1b, 0x1b)
      scheme.foreground.should eq Theme::Color.new(0xc0, 0xc0, 0xc0)
      scheme.cursor.should eq Theme::Color.new(0xff, 0xaa, 0x00)
      scheme.ansi[0].should eq Theme::Color.new(0x00, 0x00, 0x00)
      scheme.ansi[9].should eq Theme::Color.new(0xe2, 0x4a, 0x63)
      scheme.ansi[15].should eq Theme::Color.new(0xff, 0xff, 0xff)
      scheme.complete?.should be_true
    end

    it "parses YAML sources" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "yaml.yml"))

      scheme.name.should eq "YAML Test"
      scheme.foreground.should eq Theme::Color.new(0xd8, 0xd8, 0xd8)
      scheme.background.should eq Theme::Color.new(0x18, 0x18, 0x18)
      scheme.cursor.should eq Theme::Color.new(0xd8, 0xd8, 0xd8)
      scheme.cursor_text.should eq Theme::Color.new(0x10, 0x10, 0x10)
      scheme.ansi[0].should eq Theme::Color.new(0x28, 0x28, 0x28)
      scheme.ansi[15].should eq Theme::Color.new(0xf8, 0xf8, 0xf8)
      scheme.complete?.should be_true
    end

    it "parses iTerm colors (XML plist)" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "iterm.itermcolors"))

      scheme.name.should eq "iterm"
      scheme.foreground.should eq Theme::Color.new(204, 204, 204) # 0.8
      scheme.background.should eq Theme::Color.new(18, 18, 18)    # 0.07
      scheme.ansi[1].should eq Theme::Color.new(255, 0, 0)
      scheme.ansi[2].should eq Theme::Color.from_p3(0.5, 0.5, 0.5) # P3 color space entry
      scheme.ansi[3].should eq Theme::Color.new(247, 209, 84)
      scheme.cursor.should eq Theme::Color.new(255, 204, 0)
      scheme.cursor_text.should eq Theme::Color.new(0, 0, 0)
      scheme.selection_background.should eq Theme::Color.new(51, 102, 153)
      scheme.selection_foreground.should eq Theme::Color.new(255, 255, 255)
      scheme.complete?.should be_true
    end

    it "parses Terminal.app themes (binary plist)" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "terminalapp.terminal"))

      scheme.name.should eq "terminalapp"
      scheme.ansi[0].should eq Theme::Color.new(0, 0, 0)
      scheme.ansi[1].should eq Theme::Color.from_p3(0.84, 0.15, 0.24)
      scheme.ansi[15].should eq Theme::Color.new(255, 255, 255)
      scheme.foreground.should eq Theme::Color.from_p3(0.8, 0.8, 0.8)
      scheme.background.should eq Theme::Color.from_p3(0.07, 0.07, 0.07)
      scheme.cursor.should eq Theme::Color.from_p3(1.0, 0.8, 0.0)
      scheme.selection_background.should eq Theme::Color.from_p3(0.2, 0.4, 0.6)
      scheme.complete?.should be_true
    end

    it "parses Terminal.app themes with archived (nested plist) color blobs" do
      # base64 of a binary plist wrapping the float string "0.84 0.15 0.24"
      archived = "YnBsaXN0MDDRAQJVTlNSR0JOMC44NCAwLjE1IDAuMjQICxEAAAAAAAABAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAIA=="
      xml = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <plist version="1.0">
        <dict>
          <key>TextColor</key>
          <data>#{archived}</data>
        </dict>
        </plist>
        XML

      scheme = Theme::Config::Format::TerminalApp.parse(xml)
      scheme.foreground.should eq Theme::Color.from_p3(0.84, 0.15, 0.24)
    end

    it "honors an explicit format override" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "kitty.conf"), format: Theme::Config::Format::Kitty)
      scheme.foreground.should eq Theme::Color.new(0xd0, 0xd0, 0xd0)
    end
  end

  describe ".detect_format" do
    {
      {"iterm.itermcolors",     Theme::Config::Format::ITermColors},
      {"terminalapp.terminal",  Theme::Config::Format::TerminalApp},
      {"alacritty.toml",        Theme::Config::Format::Alacritty},
      {"wezterm.toml",          Theme::Config::Format::WezTerm},
      {"rio.toml",              Theme::Config::Format::Rio},
      {"windows_terminal.json", Theme::Config::Format::WindowsTerminal},
      {"vscode.json",           Theme::Config::Format::VSCode},
      {"konsole.colorscheme",   Theme::Config::Format::Konsole},
      {"foot.ini",              Theme::Config::Format::Foot},
      {"termite_config",        Theme::Config::Format::Termite},
      {"xfce4.theme",           Theme::Config::Format::Xfce4},
      {"terminator.config",     Theme::Config::Format::Terminator},
      {"kitty.conf",            Theme::Config::Format::Kitty},
      {"ghostty",               Theme::Config::Format::Ghostty},
      {"xresources.xrdb",       Theme::Config::Format::XResources},
      {"yaml.yml",              Theme::Config::Format::YamlSource},
    }.each do |file, expected|
      it "detects #{file} as #{expected}" do
        Theme::Config.detect_format(File.join(fixtures, file)).should eq expected
      end
    end

    it "raises ParseError when the format cannot be detected" do
      expect_raises(Theme::ParseError, /cannot detect format/) do
        Theme::Config.detect_format(File.join(fixtures, "unknown.xyz"))
      end
    end
  end

  describe "Format#parse" do
    it "dispatches to the parser modules" do
      text   = File.read(File.join(fixtures, "ghostty"))
      scheme = Theme::Config::Format::Ghostty.parse(text, "g")

      scheme.name.should eq "g"
      scheme.foreground.should eq Theme::Color.new(0xdd, 0xee, 0xdd)
      scheme.ansi[3].should eq Theme::Color.new(0xf7, 0xd1, 0x54)
    end
  end

  describe "Config::Scheme#set_ansi_by_name" do
    it "maps base names, bright_/light_ prefixes and the purple alias" do
      scheme = Theme::Config::Scheme.new
      red    = Theme::Color.new(255, 0, 0)

      scheme.set_ansi_by_name("red", red)
      scheme.ansi[1].should eq red

      scheme.set_ansi_by_name("bright_red", red)
      scheme.ansi[9].should eq red

      scheme.set_ansi_by_name("light_blue", red)
      scheme.ansi[12].should eq red

      scheme.set_ansi_by_name("purple", red)
      scheme.ansi[5].should eq red

      scheme.set_ansi_by_name("not_a_color", red) # ignored
      scheme.ansi.count(&.nil?).should eq 12
    end
  end

  describe "Config::Scheme#to_scheme" do
    it "converts a complete scheme, keeping cursor and selection colors" do
      config = Theme::Config.parse_file(File.join(fixtures, "kitty.conf"))
      scheme = config.to_scheme

      scheme.name.should eq "kitty"
      scheme.palette[1].should eq Theme::Color.new(0xd7, 0x26, 0x3d)
      scheme.foreground.should eq Theme::Color.new(0xd0, 0xd0, 0xd0)
      scheme.background.should eq Theme::Color.new(0x12, 0x12, 0x12)
      scheme.cursor.should eq Theme::Color.new(0xff, 0xcc, 0x00)
      scheme.selection_background.should eq Theme::Color.new(0x33, 0x55, 0x77)
    end

    it "enables Theme::Scheme features on parsed configs" do
      scheme = Theme::Config.parse_file(File.join(fixtures, "kitty.conf")).to_scheme

      scheme.dark?.should be_true
      fg = scheme.foreground.not_nil!
      bg = scheme.background.not_nil!
      bg.contrast(fg).should be > 4.5 # passes WCAG AA for normal text
    end

    it "returns nil from to_scheme? when incomplete" do
      config = Theme::Config::Format::Kitty.parse("foreground #ffffff\nbackground #000000\n")

      config.complete?.should be_false
      config.to_scheme?.should be_nil
    end

    it "raises ParseError from to_scheme when incomplete" do
      config = Theme::Config::Format::Kitty.parse("foreground #ffffff\nbackground #000000\n")

      expect_raises(Theme::ParseError, /incomplete color scheme/) { config.to_scheme }
    end
  end

  describe "Config::Scheme serialization" do
    it "round-trips through JSON" do
      scheme  = Theme::Config.parse_file(File.join(fixtures, "kitty.conf"))
      decoded = Theme::Config::Scheme.from_json(scheme.to_json)

      decoded.name.should eq scheme.name
      decoded.foreground.should eq scheme.foreground
      decoded.selection_background.should eq scheme.selection_background
      decoded.ansi.should eq scheme.ansi
    end

    it "round-trips through YAML" do
      scheme  = Theme::Config.parse_file(File.join(fixtures, "kitty.conf"))
      decoded = Theme::Config::Scheme.from_yaml(scheme.to_yaml)

      decoded.name.should eq scheme.name
      decoded.cursor.should eq scheme.cursor
      decoded.ansi.should eq scheme.ansi
    end
  end
end
