# frozen_string_literal: true

module Pubid
  module Idf
    # Base class for supplement identifiers (amendments, corrigenda).
    #
    # This class provides common attributes and behavior for all supplement
    # identifier types. Supplements wrap a base identifier and add additional
    # information like amendment/corrigendum number and date.
    #
    # Supplement identifiers should inherit from this class, not from
    # SingleIdentifier (which is for base documents only).
    #
    # Architecture Note:
    # - Supplements have a base_identifier attribute (recursive structure)
    # - Supplements share the to_s rendering pattern
    # - Supplements inherit typed_stage from base Identifier class
    class SupplementIdentifier < Identifier
      attribute :base_identifier, Identifier

      # Render supplement identifier as string.
      #
      # Format: "base_identifier/ABBREVIATION number:year"
      # Example: "IDF 125:1988/AMD 1:2023"
      #
      # @param lang [Symbol] Language (default: :en)
      # @param lang_single [Boolean] Use single-char language codes (default: false)
      # @param with_edition [Boolean] Include edition (default: false)
      # @return [String] String representation of supplement
      def to_s(lang: :en, lang_single: false, with_edition: false)
        [
          base_identifier.to_s(lang: lang, lang_single: lang_single,
                               with_edition: with_edition),
          "/",
          typed_stage.abbreviation,
          " ",
          number.value,
          (date ? ":#{date.year}" : ""),
        ].join("")
      end
    end
  end
end
