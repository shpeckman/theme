# src/theme/config/mini_toml.cr
module Theme::Config
  alias TOMLValue = Hash(String, TOMLValue) | Array(String) | String

  # Minimal TOML reader covering what terminal theme files use:
  # `[section]` / `[nested.section]` headers, `key = "string"` pairs and
  # single-line arrays of strings, with `#` comments (quote-aware).
  #
  # It does not support multi-line arrays, inline tables, or non-string
  # scalar types.
  module MiniTOML
    extend self

    def parse(text : String) : Hash(String, TOMLValue)
      root    = Hash(String, TOMLValue).new
      current = root
      text.each_line do |raw|
        line = strip_comment(raw).strip
        next if line.empty?

        if line.starts_with?('[') && line.ends_with?(']')
          current = root
          line[1..-2].split('.').each do |part|
            part = part.strip
            current = (current[part] ||= Hash(String, TOMLValue).new)
              .as(Hash(String, TOMLValue))
          end
        elsif line.includes?('=')
          key, _, value = line.partition('=')
          current[key.strip] = parse_value(value.strip)
        end
      end
      root
    end

    private def strip_comment(line : String) : String
      quote : Char? = nil
      line.each_char_with_index do |ch, i|
        if q = quote
          quote = nil if ch == q
        elsif ch == '\'' || ch == '"'
          quote = ch
        elsif ch == '#'
          return line[0, i]
        end
      end
      line
    end

    private def parse_value(value : String) : TOMLValue
      if value.starts_with?('[')
        inner = value.lchop('[').rchop(']')
        inner.split(',').map { |s| unquote(s.strip) }.reject(&.empty?)
      else
        unquote(value)
      end
    end

    private def unquote(s : String) : String
      if s.size >= 2 && (s.starts_with?('\'') || s.starts_with?('"'))
        s[1..-2]
      else
        s
      end
    end
  end
end
