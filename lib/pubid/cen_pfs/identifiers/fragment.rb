module Pubid
  module CenPfs
    module Identifiers
      # The fragment wrapper: a fragment of the amendment it
      # wraps; the fragment ordinal is its own `number`.
      class Fragment < ::Pubid::CenPfs::Identifier
        attribute :base, ::Pubid::CenPfs::Identifier
        attribute :number, :string

        def base_document
          base&.base_document || self
        end

        def drop_supplements
          base || self
        end

        def mr_supplement_suffix
          mr_join_segments("frag", number)
        end

        def self.polymorphic_name
          "pubid:cencenelec:fragment"
        end
      end
    end
  end
end
