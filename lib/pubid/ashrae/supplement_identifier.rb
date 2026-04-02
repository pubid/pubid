# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ashrae
    # Base class for supplement identifiers (addendums, errata, interpretations)
    # Supplements modify or add to a base document
    class SupplementIdentifier < Identifiers::Base
      attribute :base_identifier, Identifiers::Base, polymorphic: true

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end

      # Delegate code to base_identifier
      def code
        base_identifier&.code
      end
    end
  end
end
