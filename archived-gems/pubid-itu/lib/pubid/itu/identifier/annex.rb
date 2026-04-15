module Pubid
  module Itu
    module Identifier
      class Annex < Supplement
        def_delegators "Pubid::Itu::Identifier::Annex", :type

        attribute :base, :string

        def initialize(base: nil, **opts)
          super(**opts)
          @base = base
        end

        def self.type
          { key: :annex, title: "Annex" }
        end
      end
    end
  end
end
