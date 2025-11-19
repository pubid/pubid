require_relative "../single_identifier"
require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/vap_suffix"
require_relative "../components/trf_info"

module PubidNew
  module Iec
    module Identifiers
      # Base class for all IEC identifiers
      # Inherits from SingleIdentifier to get common functionality
      # Single Responsibility: Common IEC identifier attributes and behavior
      class Base < SingleIdentifier
        # IEC-specific attributes
        attribute :vap_suffix, Components::VapSuffix, default: -> { nil }
        attribute :trf_info, Components::TrfInfo, default: -> { nil }
        attribute :database, :boolean, default: -> { false }
        attribute :fragment, :string, default: -> { nil }
        attribute :version, :string, default: -> { nil }
        attribute :decision_sheet, :string, default: -> { nil }

        def to_s(format = :short)
          parts = []

          # Publisher and type portion (from typed_stage) - uses inherited method
          parts << publisher_portion

          # Number portion (number with part/subpart)
          parts << number_portion

          # Edition if present - add space before edition
          parts << " #{edition.to_s}" if edition && edition.number

          # VAP suffix
          parts << vap_suffix.render_with_space if vap_suffix

          # Database flag
          parts << " DB" if database

          parts.compact.join
        end

        def number_portion
          return "" unless number

          result = " #{number.to_s}"

          # Add part if present
          result += "-#{part.to_s}" if part && part.to_s != ""

          # Add subpart if present
          result += "-#{subpart.to_s}" if subpart && subpart.to_s != ""

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

          # Validate VAP suffix if present
          vap_suffix&.validate!

          # Validate TRF info if present
          trf_info&.validate! if trf_info && !trf_info.empty?
        end
      end
    end
  end
end