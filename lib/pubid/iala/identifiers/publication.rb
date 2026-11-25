# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # An IALA publication with no code: iala.int lists reports and
      # proceedings, the style guide, history books and radio plans with
      # no series letter or number, and its product-URL slug is the only
      # identity the document has.
      #
      # The slug is held in the inherited `number` attribute, so it is
      # also the index key (`root.number`) and serializes as `number`.
      #
      # Examples:
      #   IALA arctic-seminar-report
      #   IALA arctic-seminar-report (E)
      #   IALA iala-style-guide Ed 1.0 (E)
      class Publication < Identifier
        def self.type
          { key: :publication, title: "Publication", short: nil }
        end

        # IALA assigns no MRN to a codeless publication, so it has no
        # official URN; #to_pubid_urn still names it.
        def to_urn
          nil
        end
      end
    end
  end
end
