# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Base class for supplement identifiers (amendments, corrigenda, interpretations, etc.)
      # Supplements modify or add to a base document
      class SupplementIdentifier < Base
        attribute :base, Base, polymorphic: true

        # Delegate publisher to base
        def publisher
          base&.publisher
        end

        # Delegate code to base if not overridden
        def code
          base&.code
        end
      end
    end
  end
end
