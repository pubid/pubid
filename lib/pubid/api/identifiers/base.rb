# frozen_string_literal: true

module Pubid
  module Api
    module Identifiers
      class Base < SingleIdentifier
        # Base class for all API identifiers
        # Inherits common attributes from SingleIdentifier

        # Include type_string in serialization for round-trip compatibility
        def base_hash
          hash = super
          if self.class.attributes.key?(:type_string) && type_string
            hash[:type] =
              type_string
          end
          hash
        end
      end
    end
  end
end
