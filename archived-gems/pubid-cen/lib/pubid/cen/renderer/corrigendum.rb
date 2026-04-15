require_relative "base"

module Pubid
  module Cen
    module Renderer
      class Corrigendum < Pubid::Core::Renderer::Base
        def render_identifier(params)
          if params[:base].is_a?(Identifier::Base)
            "%<base>s/AC%<number>s%<year>s" % params
          else
            "+AC%<number>s%<year>s" % params
          end
        end
      end
    end
  end
end
