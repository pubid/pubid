# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        # The ordinal and the year live in `number` (inherited, already a
        # `:string`) and a declared `year`, exactly as on Amendment — see that
        # class for why the year is not the inherited `date` (`#exclude`
        # recurses, so `exclude(:date)` would drop a supplement's own year) and
        # why it is a `:string` (relaton compares the year across supplement
        # classes and flavors, so it must not change type with the class).
        #
        # The `year` is nil for a year-less corrigendum (`BS 1234:2015+C1`),
        # which parses; `number` is in practice always set, because the grammar
        # requires a digit after the `C` — the unnumbered `+C:2016` form that
        # CEN spells `AC` does not parse in BSI at all.
        attribute :year, :string
        attribute :separator, :string, default: -> { "+" }

        def publisher
          base&.publisher
        end

        # Base document = the standard this corrigendum applies to, fully peeled.
        def base_document
          base&.base_document || self
        end

        # Dropping the supplement layer yields the base standard.
        def drop_supplements
          base || self
        end

        # Names the supplement class, so callers need not special-case it. The
        # ordinal and the year need no such method: Amendment and Corrigendum —
        # in BSI and in CEN — all declare them as `number` and `year`.
        def supplement_type
          :corrigendum
        end
      end
    end
  end
end
