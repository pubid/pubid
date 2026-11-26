# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # IHO Capacity Building Publication (C series; S-11 Part C Ed 1.0.0
      # section 1.2: "C - Capacity Building Publications" — the MRN
      # guidance's `cb` publication type).
      # Example: IHO C-13 1.0.0 (the Manual on Hydrography).
      class CapacityBuilding < Identifier
        def self.type
          { key: :capacity_building, title: "Capacity Building Publication",
            short: "C" }
        end

        # The auto-derived name kebab-cases to "capacity-building"; the
        # wire type keeps the underscore spelling (the domain term, the
        # type key's own shape) — the bsi_pfs hard-return precedent.
        def self.polymorphic_name
          "pubid:iho:capacity_building"
        end
      end
    end
  end
end
