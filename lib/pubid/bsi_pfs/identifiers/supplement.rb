module Pubid
  module BsiPfs
    module Identifiers
      # The supplement wrapper base: the wrapper owns its ordinal
      # and the base identifier; every delegated attribute reads
      # through (the coded SupplementIdentifier shape).
      class Supplement < ::Pubid::BsiPfs::Identifier
        attribute :base, ::Pubid::BsiPfs::Identifier
        attribute :number, :string
        attribute :year, :string

        def base_document
          base&.base_document || self
        end

        def drop_supplements
          base || self
        end

        # The printed notation: the kind face, the ordinal (absent
        # for an unnumbered corrigendum) and the declared date tail.
        # The bare notation; the renderer's walkers add the
        # standalone slash and the consolidated plus themselves.
        def supplement_notation
          "#{self.class.face}#{number}#{year ? ":#{year}" : ''}"
        end

      end
    end
  end
end
