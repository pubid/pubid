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
    # - Supplements have a base attribute (recursive structure)
    # - Supplements share the to_s rendering pattern
    # - Supplements inherit typed_stage from base Identifier class
    class SupplementIdentifier < Identifier
      attribute :base, Identifier

      # Render supplement identifier as string.
      #
      # Format: "base/ABBREVIATION number:year"
      # Example: "IDF 125:1988/AMD 1:2023"
      #
      # @param lang [Symbol] Language (default: :en)
      # @param lang_single [Boolean] Use single-char language codes (default: false)
      # @param with_edition [Boolean] Include edition (default: false)
      # @return [String] String representation of supplement
      def to_s(**opts)
        render(format: :human, **opts)
      end
    end
  end
end
