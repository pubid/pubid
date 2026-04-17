require_relative "base"

module Pubid
  module Bsi
    module Renderer
      class Flex < Base
        TYPE = "Flex".freeze

        def render_identifier(params)
          suffix = "%<year>s%<month>s%<supplement>s%<tracked_changes>s%<translation>s%<pdf>s" % params

          "%<publisher>s %<number>s%<part>s%<edition>s#{suffix}" % params
        end

        def render_publisher(_publisher, _, _)
          "BSI #{TYPE}"
        end
      end
    end
  end
end
