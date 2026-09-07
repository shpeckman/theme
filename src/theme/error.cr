# src/theme/error.cr
module Theme
  class Error < Exception; end

  class ParseError < Error; end
end
