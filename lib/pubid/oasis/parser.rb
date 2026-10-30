# frozen_string_literal: true

module Pubid
  module Oasis
    # Grammar for printed OASIS identifiers, e.g.
    #   "OASIS OSLC-CoreShapes-3.0-PS01-Pt8"
    #   "OASIS amqp-core"
    #
    # OASIS slugs are free-form with a highly inconsistent internal structure
    # (varying fragment order, three part spellings, mixed case, a few
    # malformed records with spaces or stray characters). The grammar therefore
    # only strips the "OASIS " publisher prefix and captures the remainder
    # verbatim; the spec/version/stage/part/label decomposition is done in the
    # Builder with order-independent fragment classification. Keeping
    # decomposition out of the PEG avoids brittle backtracking and guarantees a
    # lossless round-trip.
    class Parser
    end
  end
end
