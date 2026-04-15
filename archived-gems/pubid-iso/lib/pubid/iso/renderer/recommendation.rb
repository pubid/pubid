require_relative "base"

module Pubid
  module Iso
    module Renderer
      class Recommendation < Base
        TYPE = "R".freeze

        def omit_post_publisher_symbol?(_typed_stage, _stage, _opts)
          # always need post publisher symbol, because we always have to add "R"
          false
        end
      end
    end
  end
end
