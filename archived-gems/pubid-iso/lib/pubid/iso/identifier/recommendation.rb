require_relative "../renderer/recommendation"

module Pubid
  module Iso
    module Identifier
      class Recommendation < Base
        def_delegators "Pubid::Iso::Identifier::Recommendation", :type

        TYPED_STAGES = {}.freeze

        def self.type
          { key: :r, title: "Recommendation", short: "R" }
        end

        def self.get_renderer_class
          Renderer::Recommendation
        end
      end
    end
  end
end
