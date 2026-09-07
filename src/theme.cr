# src/theme.cr
require "./theme/error"
require "./theme/color"
require "./theme/lab"
require "./theme/scheme"
require "./theme/config"

module Theme
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
