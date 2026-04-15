# frozen_string_literal: true

module Pubid
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
      attribute :original_code, :string # Store the actual parsed format

      def to_s(lang_single: false)
        # When multi-char format requested (lang_single: false) but original was
        # single-char, normalize to multi-char (for with_edition: true mode)
        if !lang_single && original_code&.length == 1
          # Normalize single-char to multi-char
          code
        elsif original_code
          # Preserve original format if requesting same format
          original_code
        else
          # No original, use requested format
          lang_single ? CHAR_MAP.key(code) : code
        end
      end
    end
  end
end
