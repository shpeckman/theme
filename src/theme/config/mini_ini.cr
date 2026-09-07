# src/theme/config/mini_ini.cr
module Theme::Config
  # Minimal INI reader: `[section]` headers and `key = value` pairs, with
  # `;` and `#` full-line comments. Repeated sections are merged. Keys seen
  # before the first section header are discarded.
  module MiniINI
    extend self

    def parse(text : String) : Hash(String, Hash(String, String))
      root    = Hash(String, Hash(String, String)).new
      current = Hash(String, String).new

      text.each_line do |raw|
        line = raw.strip
        next if line.empty? || line.starts_with?(';') || line.starts_with?('#')

        if line.starts_with?('[') && line.ends_with?(']')
          current = (root[line[1..-2].strip] ||= Hash(String, String).new)
        elsif line.includes?('=')
          key, _, value = line.partition('=')
          current[key.strip] = value.strip
        end
      end
      root
    end
  end
end
