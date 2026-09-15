# frozen_string_literal: true

module Pubid
  module Evs
    module Identifiers
      # The EVS national adoption of a European Standard.
      # Example: "EVS-EN 18216:2026"
      class NationalAdoption < ::Pubid::Evs::Identifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        def self.type
          { key: :evs_en, title: "EVS National Adoption of a European Standard" }
        end
      end
    end
  end
end
