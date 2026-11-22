# frozen_string_literal: true

module Pubid
  module Wmo
    module Identifiers
      # The WMO-No. publication series: "WMO-No. 8", "WMO-No. 49",
      # "WMO-No. 1364". Editions are calendar years — "2025 edition" —
      # never version ordinals; the MRN edition segment is ed<year>
      # (urn:mrn:wmo:pub:wmo-1364:ed2025).
      class Publication < Identifier
        def self.type
          { key: :publication, title: "Publication", short: nil }
        end
      end
    end
  end
end
