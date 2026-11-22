# frozen_string_literal: true

module Pubid
  module Wmo
    module Identifiers
      # An annex to a WMO-published S-100 product specification:
      # "S-411 Annex A" (the Data Classification and Encoding Guide's
      # docidentifier in metanorma/S-411-Product-Specification). The
      # marker case is preserved (Annex vs ANNEX) for round-trip
      # fidelity; the optional edition applies to the annex itself,
      # not the base.
      class Annex < Identifier
        # The specification this annex supplements. Always present;
        # carries the S-number (e.g. S-411).
        attribute :base, ::Pubid::Wmo::Identifier, polymorphic: true
        # "Annex" or "ANNEX" — preserved verbatim for exact round-trip.
        attribute :annex_form, :string
        # "A", "B", … or nil for the bare form.
        attribute :letter, :string

        key_value do
          map "base",       to: :base
          map "annex_form", to: :annex_form
          map "letter",     to: :letter
        end

        def self.type
          { key: :annex, title: "Annex", short: nil }
        end

        # MR string: the base head, then the annex marker (and letter),
        # then the annex's own edition — "wmo.411_annex-a.ed1.2.0".
        # Returning non-nil is what makes the shared MrString renderer
        # recurse into `base` for the head.
        def mr_supplement_suffix
          segments = [letter ? "annex-#{letter.downcase}" : "annex"]
          segments << "ed#{edition}" if edition
          segments.join(".")
        end
      end
    end
  end
end
