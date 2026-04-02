# frozen_string_literal: true

module Pubid
  module Jcgm
    # Base class for JCGM supplement identifiers (amendments, corrigenda, etc.)
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :iteration, Pubid::Components::Code

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end
    end
  end
end
