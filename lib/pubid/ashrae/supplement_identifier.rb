# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ashrae
    # Base class for supplement identifiers (addendums, errata, interpretations)
    # Supplements modify or add to a base document
    class SupplementIdentifier < Identifiers::Base
      attribute :base, Identifiers::Base, polymorphic: true

      # Delegate publisher to base
      def publisher
        base&.publisher
      end

      # Delegate code to base
      def code
        base&.code
      end
    end
  end
end
