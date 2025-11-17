module PubidNew
  module Components
    # Language component (typically a language code)
    class Language < Lutaml::Model::Serializable

      CHAR_MAP = {
        "R" => "ru",
        "F" => "fr",
        "E" => "en",
        "A" => "ar",
        "S" => "es",
        "D" => "de",
      }.freeze

      # code is always an ISO 639-1 two-letter code
      attribute :code, :string, values: CHAR_MAP.values
      attribute :original_code, :string  # Store the actual parsed format

      def to_s(lang_single: false)
        # Use original parsed format if available
        return original_code if original_code
        # Otherwise use the format requested via parameter
        lang_single ? CHAR_MAP.key(code) : code
      end
    end
  end
end
