# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA S-100-family product specifications — the S-201..S-299 range
      # IHO granted IALA (iala.int, "IALA S-200 Product Specification and
      # Development Status": "This range, which spans from S-201 to S-299,
      # is compliant with the IHO S-100 standard"). The lexical form is
      # hyphenated ("S-201"), unlike the legacy zero-padded S series
      # (S1010); the edition is the S-100 dotted x.y.z on the bare face
      # ("IALA S-201 2.0.0", the form iala.int cites). "Ed 2.0.0" and the
      # compact ":ed2.0.0" parse as normalizing aliases.
      #
      # WMO publishes its own S-100 specifications in the same lexical
      # shape ("S-411 1.2.1") — the hundreds digit is each org's grant:
      # 2 is IALA's, so this class never captures another org's S-series
      # (pubid#763's dual-perspective ruling: the lexical form leads no
      # prefix; each org assigns its own identifier).
      class ProductSpecification < Identifier
        # No type letter: the "S" of "S-201" is part of the hyphenated
        # code face, rendered by the Renderer/UrnGenerator directly. A
        # short here would collide with Standard's "S" in the
        # per-letter class table.
        def self.type
          { key: :product_specification, title: "Product Specification",
            short: nil }
        end

        # The hyphenated S-number is a designation, not a publisher
        # token: the canonical face is bare ("S-201 2.0.0", iala.int's
        # own citation form), so there is no publisher prefix for
        # with_publisher to cut (the WMO S-100 rule).
        def publisher_prefixes
          []
        end
      end
    end
  end
end
