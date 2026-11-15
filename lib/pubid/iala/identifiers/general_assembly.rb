# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA General Assembly resolutions. Two printed forms carry the
      # same class:
      #
      # - dotted series.index: GA01.01, GA01.13 — the form the
      #   relaton-data-iala catalogue registers for session A-1 onwards
      #   (26 primary docidentifiers).
      # - legacy dashed session form: A12-01, A13-04 — the form the
      #   catalogue and the published covers use for the A-12/A-13
      #   sessions (all 11 A-shaped primary docidentifiers in the
      #   catalogue are GA resolutions; the shape carries no Advice).
      # No edition. The two forms are distinguished by number shape
      # (dotted GA numbers vs dashed A numbers) and rendered verbatim
      # through to_s and the MRN URN; no extra attribute is stored.
      class GeneralAssembly < Identifier
        number_width 2
        dotted_segment_width 2

        def self.type
          { key: :"general-assembly", title: "General Assembly Resolution",
            short: "GA" }
        end

        # The legacy A-session letter renders for dashed numbers
        # (A12-01); dotted numbers carry the canonical GA letter.
        def type_letter
          number.to_s.include?("-") ? "A" : super
        end

        # DSL: declare additional type letters that route to this class.
        # The legacy A-session letter resolves here as well.
        def self.type_letter_aliases(*letters)
          @type_letter_aliases = letters if letters.any?
          @type_letter_aliases || []
        end

        type_letter_aliases "A"
      end
    end
  end
end
