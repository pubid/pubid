module Pubid
  module Iec
    module Renderer
      class UrnSupplement < ::Pubid::Core::Renderer::Urn
        def render_number(number, _opts, params)
          if params[:year]
            ":v#{number}"
          else
            ":#{number}:v1"
          end
        end
      end
    end
  end
end
