# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Fragment Identifier - wraps an Amendment with a fragment number
      # Example: "EN 60038 AMD1 FRAG2" = Fragment 2 of Amendment 1 to EN 60038
      class Fragment < Base
        attribute :base_identifier, Amendment
        attribute :fragment_number, :string

        def publisher
          base_identifier&.base_identifier&.publisher
        end
      end
    end
  end
end
