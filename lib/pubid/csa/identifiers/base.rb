# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      class Base < SingleIdentifier
        def to_s(**opts)
          render(format: :human, **opts)
        end
      end
    end
  end
end
