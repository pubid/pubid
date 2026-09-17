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
        # The year is a REAL `year` attribute and deliberately not the
        # inherited `date`, the other way to reach the same `year:` key. An
        # amendment's year belongs to the supplement, not to the standard, and
        # `#exclude` recurses into nested identifiers — so holding it in `date`
        # made `exclude(:date)` on the consolidated identifier drop the
        # amendment's year too ("BS 7273-4+A1:2021" rendered as
        # "BS 7273-4+A1"), conflating the two. A declared `year` is the shape
        # ashrae, bipm, gost, ieee, jis, nist and ogc already use, and the
        # canonical flat serialization leaves it alone for exactly that reason.
        #
        # `:string`, not `:integer`, to match the year every other BSI
        # identifier carries (a `Components::Date` year is a String) and the
        # base `#year` reader, which is `date&.year&.to_s`. It also has to match
        # CEN, whose supplements carry a `:string` `year` too: relaton reads the
        # year off a supplement of either flavor and compares it, so the two
        # must not differ in type.
        attribute :year, :string
        attribute :separator, :string, default: -> { "+" }
        # true for the trailing " AMD5" / " AMD AA" suffix form, false for the
        # compact "+A5" / "/A5" join form. Distinguishes the two when no year is
        # present (previously the presence of a year was a reliable proxy).
        attribute :amd_suffix_form, :boolean, default: -> { false }

        def publisher
          base&.publisher
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
