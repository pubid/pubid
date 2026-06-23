# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Base class for all IEC identifiers
      # Inherits from SingleIdentifier to get common functionality
      # Single Responsibility: Common IEC identifier attributes and behavior
      class Base < SingleIdentifier
        # IEC-specific attributes. VAP codes live on VapIdentifier, not here.
        attribute :trf_info, Components::TrfInfo, default: -> {}
        attribute :database, :boolean, default: -> { false }
        attribute :fragment, :string, default: -> {}
        attribute :version, :string, default: -> {}
        attribute :decision_sheet, :string, default: -> {}

        # database is the only Base-specific serialized key (emitted when set);
        # merged onto the common map inherited from Identifier.
        key_value do
          map "database", to: :database, render_default: false
        end

        def to_s(**opts)
          render(format: :human, **opts)
        end

        def number_portion
          return "" unless number

          result = " #{number}"

          # Add part if present
          result += "-#{part}" if part && part.to_s != ""

          # Add subpart if present
          result += "-#{subpart}" if subpart && subpart.to_s != ""

          # Add date if present
          result += ":#{date.year}" if date

          result
        end

        def self.type
          raise NotImplementedError, "Subclass must implement self.type method"
        end

        # Validate IEC-specific constraints
        def validate!
          super if defined?(super)

          # Validate TRF info if present
          trf_info&.validate! if trf_info && !trf_info.empty?
        end
      end
    end
  end
end
