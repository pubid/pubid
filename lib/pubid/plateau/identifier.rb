# frozen_string_literal: true

module Pubid
  module Plateau
    # Plateau factory entry point. `.parse` lives on `Pubid::Plateau`
    # itself for historical reasons; this module hosts `.create` for API
    # consistency with the other pubid flavors.
    module Identifier
      # Delegate to the flavor module so callers can use
      # `Pubid::Plateau::Identifier.parse` consistently with other flavors.
      def self.parse(identifier)
        Pubid::Plateau.parse(identifier)
      end
    end
  end
end
