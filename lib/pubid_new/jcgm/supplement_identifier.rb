# frozen_string_literal: true

require_relative "identifier"
require_relative "single_identifier"
require_relative "../components/code"

module PubidNew
  module Jcgm
    # Base class for JCGM supplement identifiers (amendments, corrigenda, etc.)
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :iteration, PubidNew::Components::Code

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end
    end
  end
end