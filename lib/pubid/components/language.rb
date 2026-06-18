# frozen_string_literal: true

module Pubid
  module Components
    # Language component (typically a language code)
    #
    # Human render: language code, optionally single-char.
    # URN render: lowercase ISO 639-1 code (RFC 5141-bis).
    class Language < Lutaml::Model::Serializable
      CHAR_MAP = {
        "R" => "ru",
        "F" => "fr",
        "E" => "en",
        "A" => "ar",
        "S" => "es",
        "D" => "de",
      }.freeze

      attribute :code, :string, values: CHAR_MAP.values
      attribute :original_code, :string

      def to_s(lang_single: false)
        if !lang_single && original_code&.length == 1
          code
        elsif original_code
          original_code
        else
          lang_single ? CHAR_MAP.key(code) : code
        end
      end

      def render(context: nil, **opts)
        return code&.downcase if context&.urn?

        to_s(**opts)
      end
    end
  end
end
