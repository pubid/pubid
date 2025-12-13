# frozen_string_literal: true

module PubidNew
  module Oiml
    class SupplementIdentifier < Identifier
      # Base class for OIML supplements (amendments, annexes)
      # These wrap a base identifier like ISO amendments
      attribute :base_identifier, Oiml::Identifier
      attribute :year, :string
      attribute :language, :string

      def to_s
        result = "#{supplement_type} (#{year}) to #{base_identifier}"
        result += " (#{language})" if language
        result
      end

      # Subclasses override this
      def supplement_type
        raise NotImplementedError, "Subclasses must implement supplement_type"
      end
    end
  end
end