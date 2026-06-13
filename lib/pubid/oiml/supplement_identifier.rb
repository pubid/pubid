# frozen_string_literal: true

module Pubid
  module Oiml
    class SupplementIdentifier < Identifier
      # Base class for OIML supplements (amendments, annexes)
      # These wrap a base identifier like ISO amendments
      attribute :base_identifier, Oiml::Identifier
      attribute :year, :string
      attribute :language, :string
      attribute :parsed_format, :string, default: -> {
        "short"
      } # Track supplement's parsed format

      attr_reader :requested_format

      def to_s(format: nil, **opts)
        @requested_format = format
        render(format: :human, **opts)
      end

      # Subclasses override this
      def supplement_type
        raise NotImplementedError, "Subclasses must implement supplement_type"
      end
    end
  end
end
