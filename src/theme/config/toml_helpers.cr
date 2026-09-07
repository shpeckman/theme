# src/theme/config/toml_helpers.cr
module Theme::Config
  # Shared accessors for the TOML-based formats (Alacritty, WezTerm, Rio).
  private module TomlHelpers
    private def table(h : Hash(String, TOMLValue), key : String) : Hash(String, TOMLValue)?
      h[key]?.as?(Hash(String, TOMLValue))
    end

    private def hex(h : Hash(String, TOMLValue), key : String) : Color?
      h[key]?.as?(String).try { |s| Color.parse(s) }
    end
  end
end
