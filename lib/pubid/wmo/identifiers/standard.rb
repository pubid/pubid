# frozen_string_literal: true

module Pubid
  module Wmo
    module Identifiers
      # The WMO-published S-100 product specifications: the IHO S-100
      # lexical form ("S-411", "S-412") with WMO as the assigning
      # authority — the S-201-of-IALA type assignment of the #763
      # ruling. Editions are the S-100 dotted x.y.z ("S-411 1.2.1",
      # MRN ed1.2.1).
      class Standard < Identifier
        def self.type
          { key: :standard, title: "Standard", short: "S" }
        end
      end
    end
  end
end
