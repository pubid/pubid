# frozen_string_literal: true


require_relative "../../serializable"
require_relative "../urn_generator"
require_relative "../../components/date"
require_relative "../components/sector"
require_relative "../components/series"
require_relative "../components/code"

module Pubid
  module Itu
    module Identifiers
      # Base class for all ITU identifiers
      class Base < Lutaml::Model::Serializable
        include Pubid::Serializable

        # Generate URN for this identifier
        #
        # @return [String] URN representation
        def to_urn
          UrnGenerator.new(self).generate
        end

        # Override base_hash to handle ITU-specific attributes
        def base_hash
          hash = super
          # ITU Series has a 'series' attribute, not 'number'
          if hash[:series].is_a?(Hash)
            hash[:series] = series.series if series
          end
          # Add sector (ITU-specific, has a 'sector' attribute)
          hash[:sector] = sector.sector if sector
          hash
        end

        attribute :sector, Pubid::Itu::Components::Sector
        attribute :series, Pubid::Itu::Components::Series
        attribute :code, Pubid::Itu::Components::Code
        attribute :date, Pubid::Components::Date
        attribute :language, :string

        def publisher
          "ITU"
        end

        def to_s
          result = "#{publisher}-#{sector}"

          # Add series and code
          result += if series
                      " #{series}.#{code}"
                    else
                      " #{code}"
                    end

          # Add date if present
          if date
            result += if date.month
                        " (#{date.month}/#{date.year})"
                      else
                        " (#{date.year})"
                      end
          end

          # Add language
          result += "-#{language}" if language

          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          sector == other.sector &&
            series == other.series &&
            code == other.code &&
            date == other.date &&
            language == other.language
        end
      end
    end
  end
end
