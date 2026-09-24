# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        # The ordinal lives in `number` (inherited, already a `:string`), and
        # the year in the inherited `date` component, exactly as on Amendment
        # — see that class for why `date` is now safe to use: `#exclude`
        # protects it via `supplement_date_attributes` below, so
        # `exclude(:date)` drops only the standard's date. The flat scalar
        # serialization rule renders a degenerate `date` as a bare `year:`
        # key, so relaton still compares a plain String across supplement
        # classes and flavors.
        #
        # The year is nil for a year-less corrigendum (`BS 1234:2015+C1`),
        # which parses; `number` is in practice always set, because the grammar
        # requires a digit after the `C` — the unnumbered `+C:2016` form that
        # CEN spells `AC` does not parse in BSI at all.
        attribute :separator, :string, default: -> { "+" }

        def publisher
          base&.publisher
        end

        # See Amendment.compact_hash: the publisher is borrowed from the base
        # and must never appear on the supplement's own wire entry.
        def self.compact_hash(_model, hash)
          hash.delete("publisher")
        end

        # See the comment on `date` above: protects the corrigendum's own
        # date from a bare `exclude(:date)`/`exclude(:year)`, which otherwise
        # recurses into `base` and drops the standard's date too.
        def self.supplement_date_attributes
          %i[date]
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
