# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # MR-slug hooks for a BSI wrapper that carries no identity of its own.
      #
      # The base `mr_number_with_part` and `mr_year` read the receiver's own
      # `number`, `part`, `subpart` and `date`. A wrapper — an adoption, a
      # national annex, a consolidated edition, an Expert-commentary volume —
      # leaves all four nil and keeps the identity on the document it wraps, so
      # those hooks produced a slug with no number at all: 158 BSI identifiers
      # collapsed onto the bare `bs`, and `to_slug` is an output FILENAME.
      #
      # `#root` and not `base`: a "DD ENV ISO 11079:1999" adopts a CEN
      # EuropeanPrestandard, which is itself a wrapper around the ISO standard,
      # so one level down is not far enough. `#root` recurses, and for a
      # non-wrapper it is `self` — hence the `equal?` guard, which sends an
      # ordinary identifier to the base hooks unchanged.
      module RootIdentity
        def mr_number_with_part
          root.equal?(self) ? super : root.mr_number_with_part
        end

        def mr_year
          root.equal?(self) ? super : root.mr_year
        end
      end
    end
  end
end
