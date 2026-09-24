# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      class Amendment < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        # The amendment's ordinal lives in the `number` inherited from
        # SingleIdentifier — already a `:string` there, which is what the
        # ordinal is ("1", "11", "AA") — so the row reads `number:` rather than
        # `amendment_number:`.
        #
        # This does NOT make the ordinal a document number: the amended
        # standard is reached through `base`, and `#root` walks it, which is
        # what relaton-index keys on.
        #
        # The year lives in the inherited `date` component, the natural home:
        # an amendment's year belongs to the supplement, not to the standard,
        # and `#exclude` protects it via `supplement_date_attributes` below,
        # so `exclude(:date)` on a consolidated identifier drops only the
        # standard's date. The flat scalar serialization rule renders a
        # degenerate `date` as a bare `year:` key, matching CEN and every
        # other BSI row.
        attribute :separator, :string, default: -> { "+" }
        # true for the trailing " AMD5" / " AMD AA" suffix form, false for the
        # compact "+A5" / "/A5" join form. Distinguishes the two when no year is
        # present (previously the presence of a year was a reliable proxy).
        attribute :amd_suffix_form, :boolean, default: -> { false }

        def publisher
          base&.publisher
        end

        # `publisher` reads through to the base, so it is never this
        # amendment's own state. Lutaml only serializes the borrowed component
        # when the member came from from_hash (the parse path shares the base
        # instance, and lutaml omits the reference), which made
        # from_hash(to_hash(id)).to_hash regrow a `publisher` key the parse
        # path never emits. Drop it unconditionally to keep the wire symmetric.
        def self.compact_hash(_model, hash)
          hash.delete("publisher")
        end

        # See the comment on `date` above: protects the amendment's own date
        # from a bare `exclude(:date)`/`exclude(:year)`, which otherwise
        # recurses into `base` and drops the standard's date too.
        def self.supplement_date_attributes
          %i[date]
        end

        # Base document = the standard this amendment applies to, fully peeled.
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
          :amendment
        end
      end
    end
  end
end
