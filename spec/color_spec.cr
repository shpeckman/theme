# spec/color_spec.cr
require "./spec_helper"
require "json"
require "yaml"

describe Theme::Color do
  describe ".parse" do
    it do
      Theme::Color.parse("#ff0044").should eq Theme::Color.new(255, 0, 68)
    end

    it do
      Theme::Color.parse("00ff00").should eq Theme::Color.new(0, 255, 0)
    end

    it do
      expect_raises(Theme::ParseError) { Theme::Color.parse("#f00") }
    end

    it do
      expect_raises(Theme::ParseError) { Theme::Color.parse("invalid") }
    end
  end

  describe ".parse?" do
    it do
      Theme::Color.parse?("#ffffff").should eq Theme::Color.new(255, 255, 255)
    end

    it do
      Theme::Color.parse?("invalid").should be_nil
    end
  end

  describe "#hex" do
    it do
      Theme::Color.new(255, 0, 68).hex.should eq "#ff0044"
    end

    it do
      Theme::Color.new(0, 255, 0).hex.should eq "#00ff00"
    end
  end

  describe "#luminance" do
    it do
      Theme::Color.new(0, 0, 0).luminance.should eq 0.0
    end

    it do
      Theme::Color.new(255, 255, 255).luminance.should be_close(1.0, 0.0001)
    end
  end

  describe "#contrast" do
    it do
      c1 = Theme::Color.new(0, 0, 0)
      c2 = Theme::Color.new(255, 255, 255)

      c1.contrast(c2).should be_close(21.0, 0.01)
      c2.contrast(c1).should be_close(21.0, 0.01)
    end

    it do
      c = Theme::Color.new(128, 128, 128)
      c.contrast(c).should eq 1.0
    end
  end

  describe "#perceived_luminance" do
    it do
      Theme::Color.new(0, 0, 0).perceived_luminance.should eq 0.0
    end

    it do
      Theme::Color.new(255, 255, 255).perceived_luminance.should be_close(1.0, 0.0001)
    end
  end

  describe "Serialization" do
    it "serializes and deserializes JSON" do
      color = Theme::Color.new(255, 0, 68)
      json  = color.to_json
      json.should eq %("#ff0044")
      Theme::Color.from_json(json).should eq color
    end

    it "serializes and deserializes YAML" do
      color = Theme::Color.new(255, 0, 68)
      yaml  = color.to_yaml
      Theme::Color.from_yaml(yaml).should eq color
    end
  end
end
