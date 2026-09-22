# frozen_string_literal: true

module Pubid
  module Amca
    module Identifiers
      # Publication identifier for ACMA publications
      # Examples:
      # - AMCA Publication 211-22 (Rev. 01-23)
      # - AMCA Publication 311-16
      # - AMCA Publication 1011-03 (R2010)
      class Publication < Identifier
        attribute :number, :string

        # Was a hand-written keyword initializer assigning ivars directly,
        # which bypassed lutaml entirely. Three things broke as a result: no
        # `_type` was emitted (so Identifier.from_hash could not route back to
        # this class), the `publisher` default never materialised, and
        # `revision` was a plain attr_reader that to_hash dropped. Removing it
        # — and making `revision` a real attribute — is the AIEE/IRE/NESC
        # migration applied here; the builder already calls `new(**attributes)`
        # exactly as it does for Standard, which never had this problem.
        attribute :revision, :string

        key_value do
          map "revision", to: :revision
        end

        def self.type
          { key: :publication, title: "Publication", short: nil }
        end

        # `revision` is Publication's edition/version discriminator and is
        # not in the default %i[date year edition version] list, so
        # #to_all_parts/#=== failed to collapse two revisions of the same
        # publication (e.g. "AMCA Publication 211-22 (Rev. 01-23)" vs
        # "... (Rev. 02-23)"). Declared here, not on the shared
        # Pubid::Amca::Identifier base, because `revision` is
        # Publication-only — Standard and Interpretation don't carry it.
        # `super` also picks up `reaffirmed`, added on the shared base
        # (identifiers/base.rb) since Standard carries that one too.
        def self.all_parts_edition_keys
          super + %i[revision]
        end
      end
    end
  end
end
