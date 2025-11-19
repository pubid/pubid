require "lutaml/model"

module PubidNew
  module Iec
    module Components
      # Individual Amendment within a consolidated chain
      # Single Responsibility: Represents a single amendment with number and year
      class Amendment < Lutaml::Model::Serializable
        attribute :number, :string
        attribute :year, :string, default: -> { nil }

        def to_s
          result = "AMD#{number}"
          result += ":#{year}" if year
          result
        end
      end

      # Consolidated Amendment component for chained amendments
      # Single Responsibility: Represents multiple amendments combined with + notation
      # Example: +AMD1:2020+AMD2:2022
      class ConsolidatedAmendment < Lutaml::Model::Serializable
        attribute :amendments, Amendment, collection: true

        def to_s
          amendments.map { |amd| "+#{amd.to_s}" }.join
        end

        # Parse consolidated amendment string like "+AMD1:2020+AMD2:2022"
        # Each amendment has number and optional year
        def self.parse(string)
          amendment_parts = string.split('+').reject(&:empty?)

          amendments = amendment_parts.map do |part|
            # Parse "AMD1:2020" format
            if part =~ /AMD(\d+):(\d{4})/
              Amendment.new(number: $1, year: $2)
            elsif part =~ /AMD(\d+)/
              Amendment.new(number: $1)
            else
              nil
            end
          end.compact

          new(amendments: amendments)
        end

        # Check if this consolidated amendment is empty
        def empty?
          amendments.nil? || amendments.empty?
        end

        # Count of amendments in the chain
        def count
          amendments&.size || 0
        end
      end
    end
  end
end