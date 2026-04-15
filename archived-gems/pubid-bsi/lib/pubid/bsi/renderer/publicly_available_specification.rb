require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class PubliclyAvailableSpecification < Base
        TYPE = "PAS".freeze

        def render_publisher(_publisher, _, _)
          TYPE
        end
      end
    end
  end
end
