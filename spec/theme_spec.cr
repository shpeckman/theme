# spec/theme_spec.cr
require "./spec_helper"

describe Theme do
  it do
    Theme::VERSION.should_not be_nil
    Theme::VERSION.should_not be_empty
  end
end
