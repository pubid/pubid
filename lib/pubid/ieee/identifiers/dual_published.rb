# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Dual Published Identifier
      # Document jointly published by two organizations
      # Example: "ANSI C37.61-1973 and IEEE Std 321-1973"
      # This means the document was published together by both organizations
      class DualPublished < Base
        # First organization's identifier
        attribute :first_identifier, Base, polymorphic: true

        # Second organization's identifier
        attribute :second_identifier, Base, polymorphic: true

        def publisher
          # Return array of both publishers
          [first_identifier&.publisher, second_identifier&.publisher].compact
        end
      end
    end
  end
end
