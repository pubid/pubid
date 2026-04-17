require_relative "base"

module Pubid
  module Cen
    module Renderer
      class TechnicalReport < Base
        def render_type(_type, _opts, _params)
          "/TR"
        end
      end
    end
  end
end
