# frozen_string_literal: true

module Pubid
  module Ansi
    # Single ANSI identifier (non-bundled)
    class SingleIdentifier < Identifier
      # Generate URN for this identifier
      #
      # @return [String] URN representation

      def to_s(**opts)
        render(format: :human, **opts)
      end
    end
  end
end
