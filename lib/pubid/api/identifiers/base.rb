# frozen_string_literal: true

require_relative "../single_identifier"

module Pubid
  module Api
    module Identifiers
      class Base < SingleIdentifier
        # Base class for all API identifiers
        # Inherits common attributes from SingleIdentifier

        # Include type_string in serialization for round-trip compatibility
        def base_hash
          hash = super
          hash[:type] = type_string if methods.include?(:type_string) && type_string
          hash
        end
      end
    end
  end
end
