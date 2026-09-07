# spec/scheme_spec.cr
require "./spec_helper"
require "json"
require "yaml"

describe Theme::Scheme do
  describe ".from_hex" do
    it do
      palette = Array(String).new(16) { |i| sprintf("#%02x%02x%02x", i, i, i) }
      scheme = Theme::Scheme.from_hex(
        palette: palette,
        name: "Hex Scheme",
        foreground: "#cccccc",
        background: "#222222"
      )

      scheme.name.should eq "Hex Scheme"
      scheme.foreground_hex.should eq "#cccccc"
      scheme.background_hex.should eq "#222222"
      scheme[5].should eq Theme::Color.new(5, 5, 5)
    end

    it do
      expect_raises(ArgumentError) do
        Theme::Scheme.from_hex(palette: ["#000000"] * 15)
      end
    end
  end

  describe "initialization" do
    it do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme = Theme::Scheme.new(
        palette: palette,
        name: "Test Scheme",
        foreground: Theme::Color.new(200, 200, 200),
        background: Theme::Color.new(30, 30, 30)
      )

      scheme.name.should eq "Test Scheme"
      scheme.foreground_hex.should eq "#c8c8c8"
      scheme.background_hex.should eq "#1e1e1e"
      scheme[5].should eq Theme::Color.new(5, 5, 5)
    end
  end

  describe "#dark? and #light?" do
    it do
      palette = StaticArray(Theme::Color, 16).new { Theme::Color.new(0, 0, 0) }
      scheme  = Theme::Scheme.new(palette, background: Theme::Color.new(10, 10, 10))

      scheme.dark?.should be_true
      scheme.light?.should be_false
    end

    it do
      palette = StaticArray(Theme::Color, 16).new { Theme::Color.new(0, 0, 0) }
      scheme  = Theme::Scheme.new(palette, background: Theme::Color.new(240, 240, 240))

      scheme.dark?.should be_false
      scheme.light?.should be_true
    end

    it do
      palette = StaticArray(Theme::Color, 16).new { |i| i == 0 ? Theme::Color.new(255, 255, 255) : Theme::Color.new(0, 0, 0) }
      scheme  = Theme::Scheme.new(palette)

      scheme.dark?.should be_false
      scheme.light?.should be_true
    end
  end

  describe "#fade_to" do
    it do
      pal1 = StaticArray(Theme::Color, 16).new { Theme::Color.new(0, 0, 0) }
      pal2 = StaticArray(Theme::Color, 16).new { Theme::Color.new(255, 255, 255) }
      s1   = Theme::Scheme.new(pal1, background: Theme::Color.new(0, 0, 0))
      s2   = Theme::Scheme.new(pal2, background: Theme::Color.new(255, 255, 255))

      steps = s1.fade_to(s2, 3)

      steps.size.should eq 3
      steps[0].background_hex.should eq "#000000"
      steps[2].background_hex.should eq "#ffffff"

      mid_bg = steps[1].background.not_nil!
      mid_bg.perceived_luminance.should be > 0.0
      mid_bg.perceived_luminance.should be < 1.0
    end

    it do
      pal1 = StaticArray(Theme::Color, 16).new { Theme::Color.new(0, 0, 0) }
      s1   = Theme::Scheme.new(pal1)

      expect_raises(ArgumentError) { s1.fade_to(s1, 1) }
    end
  end

  describe "#generate_256" do
    it do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme  = Theme::Scheme.new(palette)

      colors256 = scheme.generate_256
      colors256.size.should eq 256
      16.times { |i| colors256[i].should eq palette[i] }
    end

    it do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme  = Theme::Scheme.new(palette)

      standard   = scheme.generate_256(harmonious: false)
      harmonious = scheme.generate_256(harmonious: true)

      standard.size.should eq 256
      harmonious.size.should eq 256
    end
  end

  describe "cursor and selection colors" do
    it "default to nil" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme  = Theme::Scheme.new(palette)

      scheme.cursor.should be_nil
      scheme.cursor_text.should be_nil
      scheme.selection_foreground.should be_nil
      scheme.selection_background.should be_nil
    end

    it "can be set via the constructor and .from_hex" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme  = Theme::Scheme.new(palette, cursor: Theme::Color.new(1, 2, 3))

      scheme.cursor.should eq Theme::Color.new(1, 2, 3)
      scheme.cursor_hex.should eq "#010203"

      hexed = Theme::Scheme.from_hex(
        palette: (0..15).map { |i| sprintf("#%02x0000", i) },
        cursor: "#ffcc00",
        selection_background: "#264f78"
      )
      hexed.cursor.should eq Theme::Color.new(255, 204, 0)
      hexed.selection_background_hex.should eq "#264f78"
    end

    it "are omitted from JSON when nil" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      json    = Theme::Scheme.new(palette).to_json

      json.should_not contain "cursor"
      json.should_not contain "selection"
    end

    it "round-trip through JSON and YAML when present" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme = Theme::Scheme.new(palette,
        cursor: Theme::Color.new(255, 204, 0),
        selection_background: Theme::Color.new(38, 79, 120))

      Theme::Scheme.from_json(scheme.to_json).cursor.should eq Theme::Color.new(255, 204, 0)
      Theme::Scheme.from_yaml(scheme.to_yaml).selection_background.should eq Theme::Color.new(38, 79, 120)
    end

    it "are interpolated by #fade_to" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      a       = Theme::Scheme.new(palette, cursor: Theme::Color.parse("#000000"))
      b       = Theme::Scheme.new(palette, cursor: Theme::Color.parse("#ffffff"))

      steps = a.fade_to(b, 3)
      steps[0].cursor.should eq Theme::Color.parse("#000000")
      steps[1].cursor.should eq Theme::Color.parse("#777777")
      steps[2].cursor.should eq Theme::Color.parse("#ffffff")
    end
  end

  describe "Serialization" do
    it "serializes and deserializes JSON" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme = Theme::Scheme.new(
        palette: palette,
        name: "Test Scheme",
        foreground: Theme::Color.new(200, 200, 200),
        background: Theme::Color.new(30, 30, 30)
      )

      json    = scheme.to_json
      decoded = Theme::Scheme.from_json(json)

      decoded.name.should eq "Test Scheme"
      decoded.foreground.should eq Theme::Color.new(200, 200, 200)
      decoded.background.should eq Theme::Color.new(30, 30, 30)
      16.times { |i| decoded.palette[i].should eq palette[i] }
    end

    it "serializes and deserializes YAML" do
      palette = StaticArray(Theme::Color, 16).new { |i| Theme::Color.new(i.to_u8, i.to_u8, i.to_u8) }
      scheme = Theme::Scheme.new(
        palette: palette,
        name: "Test Scheme",
        foreground: Theme::Color.new(200, 200, 200),
        background: Theme::Color.new(30, 30, 30)
      )

      yaml    = scheme.to_yaml
      decoded = Theme::Scheme.from_yaml(yaml)

      decoded.name.should eq "Test Scheme"
      decoded.foreground.should eq Theme::Color.new(200, 200, 200)
      decoded.background.should eq Theme::Color.new(30, 30, 30)
      16.times { |i| decoded.palette[i].should eq palette[i] }
    end
  end
end
