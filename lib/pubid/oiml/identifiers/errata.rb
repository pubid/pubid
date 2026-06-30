# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      # Errata supplement, used by the trailing-word shorthand
      # "OIML R 126:2015 Errata" (the publication year lives on the base).
      class Errata < SupplementIdentifier
        def supplement_type
          "Errata"
        end
      end
    end
  end
end
