module Pubid
  module Itu
    module Renderer
      class ImplementersGuide < Base
        def render_type_series(params)
          ("%<series>sImp" % params)
        end

        def render_number(number, _opts, _params)
          number
        end
      end
    end
  end
end
