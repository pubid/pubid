require_relative "base"

module Pubid::Cen::Renderer
  class TechnicalSpecification < Base
    def render_type(_type, _opts, _params)
      "/TS"
    end
  end
end
