# spec/scheme_spec.cr
require "./spec_helper"

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
end

