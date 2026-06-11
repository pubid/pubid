# frozen_string_literal: true

module Pubid
  module Amca
    # Base class for single (non-supplement) ACMA identifiers
    # Includes: Standard, Publication
    class SingleIdentifier < Identifiers::Base
      def to_s
        render(format: :human)
      end
    end
  end
end
