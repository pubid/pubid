module Pubid::Itu::Renderer
  class ImplementersGuide < Base
    def render_type_series(params)
      ("%<series>sImp" % params)
    end

    def render_number(number, _opts, _params)
      number
    end
  end
end
