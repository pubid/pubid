require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class Amendment < Pubid::Core::Renderer::Base
        def render_identifier(params)
          "+A%<number>s%<year>s" % params
        end
      end
    end
  end
end
