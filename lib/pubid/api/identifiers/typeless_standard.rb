# frozen_string_literal: true

module Pubid
  module Api
    module Identifiers
      class TypelessStandard < Base
        # No type_string method - renders without type
        def to_s
          render(format: :human)
        end
      end
    end
  end
end
