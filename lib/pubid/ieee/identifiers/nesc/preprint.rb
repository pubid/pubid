# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      module Nesc
        # Preprint NESC identifier — the draft stage preceding a C2 edition.
        # "Preprint" is a draft stage (the NESC's own terminology for its
        # pre-edition drafts), not a variant marker: the document IS a draft
        # of the C2 code, distinct from the published edition.
        #
        # @example
        #   nesc = Pubid::Ieee.parse("IEEE Std C2.2012.Preprint")
        #   nesc.to_s  # => "IEEE Std C2.2012.Preprint"
        class Preprint < Base
          include Pubid::Ieee::Identifiers::CodeNumber

          def self.polymorphic_name
            "pubid:ieee:nesc-preprint"
          end

          def draft?
            true
          end

          # Render preprint identifier. The canonical spelling is dotted
          # (C2.2012.Preprint); the dash spelling is a non-normalized alias.
          #
          # @param trademark [Boolean] append the IEEE trademark symbol (™/®)
          # @return [String] IEEE Std C2.YYYY.Preprint
          def to_s(trademark: false, **opts)
            body = ["C2", year, "Preprint"].compact.join(".")
            result = ["IEEE Std", body].join(" ")
            result += trademark_symbol if trademark
            annotate_plain_render(result, **opts)
          end
        end
      end
    end
  end
end
