require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class Corrigendum < Pubid::Core::Renderer::Base
        def render_identifier(params)
          "+C%<number>s%<year>s" % params
        end
      end
    end
  end
end
