require_relative "base"

module Pubid::Cen::Renderer
  class CenWorkshopAgreement < Base
    def render_publisher(_publisher, _opts, _params)
      ""
    end

    def render_type(_type, _opts, _params)
      "CWA"
    end
  end
end
