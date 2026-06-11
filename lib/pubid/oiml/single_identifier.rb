# frozen_string_literal: true

module Pubid
  module Oiml
    class SingleIdentifier < Identifier
      # Base class for OIML single identifiers (non-supplements)
      attribute :publisher, :string
      attribute :code, Oiml::Components::Code
      attribute :date, Pubid::Components::Date
      attribute :edition, :string
      attribute :stage, :string
      attribute :iteration, :string
      attribute :language, :string
      attribute :parsed_format, :string, default: -> {
        "short"
      } # Track parsed format

      # Type is determined by the subclass
      def type
        type_string
      end

      def to_s(format: nil, **opts)
        # Store requested format so the renderer can access it
        @requested_format = format
        render(format: :human, **opts)
      end

      def edition_portion
        # Deprecated - kept for compatibility
        # Use to_s(format: :long) instead
        if edition && date
          "#{edition} Edition #{date.year}"
        elsif date
          "Edition #{date.year}"
        else
          edition
        end
      end

      # Subclasses override this
      def type_string
        raise NotImplementedError, "Subclasses must implement type_string"
      end

      # Subclasses override this
    end
  end
end
