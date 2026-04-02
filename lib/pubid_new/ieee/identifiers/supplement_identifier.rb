# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # Base class for supplement identifiers (amendments, corrigenda, interpretations, etc.)
      # Supplements modify or add to a base document
      class SupplementIdentifier < Base
        attribute :base_identifier, Base, polymorphic: true

        # Delegate publisher to base_identifier
        def publisher
          base_identifier&.publisher
        end

        # Delegate code to base_identifier if not overridden
        def code
          base_identifier&.code
        end
      end
    end
  end
end
