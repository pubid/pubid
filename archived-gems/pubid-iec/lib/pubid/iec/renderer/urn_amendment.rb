require_relative "urn_supplement"

module Pubid
  module Iec
    module Renderer
      class UrnAmendment < UrnSupplement
        def render_identifier(params)
          ":amd%<year>s%<number>s" % params
        end
      end
    end
  end
end
