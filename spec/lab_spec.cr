# spec/lab_spec.cr
require "./spec_helper"

describe Theme::Lab do
  describe ".from_color and #to_color" do
    it do
      colors = [
        Theme::Color.new(255, 0, 0),
        Theme::Color.new(0, 255, 0),
        Theme::Color.new(0, 0, 255),
        Theme::Color.new(128, 128, 128),
        Theme::Color.new(255, 255, 255),
        Theme::Color.new(0, 0, 0),
      ]

      colors.each do |c|
        Theme::Lab.from_color(c).to_color.should eq c
      end
    end
  end

  describe "#lerp" do
    it do
      lab1 = Theme::Lab.new(0.0, 0.0, 0.0)
      lab2 = Theme::Lab.new(100.0, 50.0, -50.0)

      mid = lab1.lerp(lab2, 0.5)

      mid.l.should eq 50.0
      mid.a.should eq 25.0
      mid.b.should eq -25.0
    end

    it do
      lab   = Theme::Lab.new(50.0, 10.0, -10.0)
      other = Theme::Lab.new(100.0, 20.0, -20.0)

      lab.lerp(other, 0.0).should eq lab
      lab.lerp(other, 1.0).should eq other
    end
  end
end
