# frozen_string_literal: true

module Pubid
  module Ashrae
    # Base class for single (non-supplement) ASHRAE identifiers
    # Includes: Guideline, Standard
    class SingleIdentifier < Identifiers::Base
      def to_s(**opts)
        render(format: :human, **opts)
      end
    end
  end
end
