# frozen_string_literal: true

module Pubid
  module W3c
    # Grammar for printed W3C identifiers, e.g.
    #   "W3C WD-charmod-19991129"   (type + code + date)
    #   "W3C NOTE-xml-names"        (type + code)
    #   "W3C 2dcontext"             (bare code)
    #
    # The grammar only splits off the leading maturity token; the code/date
    # boundary is resolved in the Builder, because a PEG `code` rule would
    # greedily consume the trailing date and make a `.maybe` date rule
    # unreliable. This is safe: no real W3C code ends in a same-width (4/6/8)
    # digit run, so the Builder's fixed-width trailing-date test never collides.
    class Parser
    end
  end
end
