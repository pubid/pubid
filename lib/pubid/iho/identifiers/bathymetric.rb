# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Bathymetric Publication (B series; S-11 Part C Ed 1.0.0
      # section 1.2: "B - Bathymetric Publications (Mainly related to
      # GEBCO)" — the MRN guidance's `bathy` publication type).
      # Example: IHO B-4 2.19.0.
      class Bathymetric < Identifier
        def self.type
          { key: :bathymetric, title: "Bathymetric Publication",
            short: "B" }
        end
      end
    end
  end
end
