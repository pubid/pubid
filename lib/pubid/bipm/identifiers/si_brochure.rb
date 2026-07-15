# frozen_string_literal: true

module Pubid
  module Bipm
    module Identifiers
      # The SI Brochure — a single bespoke record. The English form drops the
      # "sur le SI" phrase the French form carries.
      #
      # Printed forms (both round-trip):
      #   "BIPM SI Brochure 9e v3.01 (2019/2024, E)"
      #   "BIPM SI Brochure sur le SI 9e v3.01 (2019/2024, F)"
      class SiBrochure < Identifier
        def self.type
          { key: :si_brochure, web: :si_brochure,
            title: "SI Brochure", short: "si-brochure" }
        end
      end
    end
  end
end
