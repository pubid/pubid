# frozen_string_literal: true

module Pubid
  module Components
    # Language component (typically a language code)
    #
    # Human render: language code, optionally single-char.
    # URN render: lowercase ISO 639-1 code (RFC 5141-bis).
    class Language < Lutaml::Model::Serializable
      include ::Pubid::SubsetMatch
      include ::Pubid::EqualityIgnored

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

      # The input spelling ("E" for "en"): the `langsrc` facet of the
      # pubid-scheme URN, so `==`, `hash` and `===` skip it (issue #656).
      equality_ignored :original_code

      # An unmapped one-letter code ("X") is built with no +code+: then the
      # spelling is the only value that holds the language, so it is
      # identity and nothing is ignored.
      def equality_ignored_attributes
        code.nil? ? [] : super
      end

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
