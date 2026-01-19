# frozen_string_literal: true

require_relative "../serializable"

require_relative "identifier"

module PubidNew
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
      include PubidNew::Serializable

      # CIE uses a fixed publisher string
      def publisher
        "CIE"
      end

      attribute :year, :string
      attribute :date_separator, :string # "dash" or "colon"
    end
  end
end
