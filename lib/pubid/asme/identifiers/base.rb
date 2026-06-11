# frozen_string_literal: true

module Pubid
  module Asme
    module Identifiers
      class Base < SingleIdentifier
        def to_s
          render(format: :human)
        end
      end
    end
  end
end
