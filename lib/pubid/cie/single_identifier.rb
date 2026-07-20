# frozen_string_literal: true

module Pubid
  module Cie
    # Base class for single CIE identifiers (standards, conferences, etc.)
    # Single Responsibility: Provide common attributes for base documents
    #
    # Single identifiers are base documents that can exist independently,
    # as opposed to supplement identifiers (amendments, corrigenda) which
    # modify a base identifier.
    #
    # Classes inheriting from SingleIdentifier:
    # - Standard (common CIE publications)
    # - Conference (conference proceedings)
    # - Bundle (bundles of multiple identifiers)
    # - JointPublished (co-published with ISO/IEC)
    # - DualPublished (dual published with IEC)
    # - Identical (identical to ISO publications)
    # - TutorialBundle (tutorial bundles)
    class SingleIdentifier < Identifier
      # Stored as a plain string (always "CIE") so it round-trips through
      # to_hash/from_hash. Was a `def publisher` method, which made lutaml
      # serialize a String against the Components::Publisher attribute and raise.
      attribute :publisher, :string, default: -> { "CIE" }

      attribute :year, :string

      # The number<->year separator character, derived from +style+ (the sole
      # separator field; there is no date_separator attribute):
      #   current -> ":"   legacy -> "-"   slash -> "/"
      def date_sep_char
        { "legacy" => "-", "slash" => "/" }.fetch(style, ":")
      end
    end
  end
end
