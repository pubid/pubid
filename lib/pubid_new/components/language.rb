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

      def to_s(lang_single: false)
        lang_single ? CHAR_MAP.key(code) : code
      end
    end
  end
end
