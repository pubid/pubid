require_relative "urn_supplement"

module Pubid
  module Iec
    module Renderer
      class UrnCorrigendum < UrnSupplement
        def render_identifier(params)
          ":cor%<year>s%<number>s" % params
        end
      end
    end
  end
end
