require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class PublishedDocument < Base
        TYPE = "PD".freeze

        def render_publisher(_publisher, _, _)
          TYPE
        end
      end
    end
  end
end
