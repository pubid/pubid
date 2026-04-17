require_relative "base"

module Pubid
  module Cen
    module Renderer
      class Guide < Base
        def render_type(_type, _opts, _params)
          " Guide"
        end
      end
    end
  end
end
