require_relative "base"

module Pubid
  module Cen
    module Renderer
      class Amendment < Pubid::Core::Renderer::Base
        def render_identifier(params)
          if params[:base].is_a?(Identifier::Base)
            "%<base>s/A%<number>s%<year>s" % params
          else
            "+A%<number>s%<year>s" % params
          end
        end
      end
    end
  end
end
