require "lutaml/model"

module PubidNew
  module Iec
    module Components
      # TRF Info component for Test Report Form specific metadata
      # Single Responsibility: Represents TRF-specific publishing information
      # Example: IECEE TRF or IECEx TRF publications
      class TrfInfo < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { nil }
        attribute :series, :string, default: -> { nil }
        attribute :version, :string, default: -> { nil }

        def to_s
          parts = []
          parts << publisher if publisher
          parts << series if series
          parts << "Ver.#{version}" if version
          parts.join(' ')
        end

        # Check if TRF info is empty (no data)
        def empty?
          publisher.nil? && series.nil? && version.nil?
        end

        # Validate that at least publisher or series is present
        def validate!
          if empty?
            raise ArgumentError, "TrfInfo must have at least publisher or series"
          end
        end
      end
    end
  end
end