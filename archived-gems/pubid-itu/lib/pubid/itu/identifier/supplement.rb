module Pubid::Itu
  module Identifier
    class Supplement < Base
      def_delegators "Pubid::Itu::Identifier::Supplement", :type

      attribute :base, :string

      def initialize(base: nil, **opts)
        super(**opts)
        @base = base
      end

      def to_h(deep: false, add_type: true)
        # XXX: hack to render supplements using Base renderer, because we need to
        # place date published after amendment, e.g. `ITU-T G.780/Y.1351 Amd 1 (2004)`
<<<<<<< HEAD:archived-gems/pubid-itu/lib/pubid/itu/identifier/supplement.rb
        @base.to_h(deep: deep).merge(type[:key] => super)
=======
        @base.to_h(deep: deep, add_type: add_type).merge(self.type[:key] => super)
>>>>>>> origin/main:gems/pubid-itu/lib/pubid/itu/identifier/supplement.rb
      end

      def self.type
        { key: :supplement, title: "Supplement" }
      end
    end
  end
end
