module Pubid
  module CenPfs
    module Identifiers
      # The supplement wrapper base: the wrapper owns its ordinal
      # and the base identifier; every delegated attribute reads
      # through (the coded SupplementIdentifier shape).
      class Supplement < ::Pubid::CenPfs::Identifier
        attribute :base, ::Pubid::CenPfs::Identifier
        attribute :number, :string
        attribute :year, :string
        attribute :month, :string

        def base_document
          base&.base_document || self
        end

        def drop_supplements
          base || self
        end

        # The wrapper's date: "2016-11", "2003", or nil.
        def supplement_date
          return nil unless year

          [year, month].compact.reject(&:empty?).join("-")
        end

        # The printed notation: the kind face, the ordinal (absent
        # for an unnumbered corrigendum) and the declared date tail.
        # The bare notation; the renderer's walkers add the
        # standalone slash and the consolidated plus themselves.
        def supplement_notation
          "#{self.class.face}#{number}#{year ? ":#{year}" : ''}#{month ? "-#{month}" : ''}"
        end

      end
    end
  end
end
