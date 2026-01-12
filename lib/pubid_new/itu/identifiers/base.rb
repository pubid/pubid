# frozen_string_literal: true

require "lutaml/model"
require_relative "../../components/date"
require_relative "../components/sector"
require_relative "../components/series"
require_relative "../components/code"

module PubidNew
  module Itu
    module Identifiers
      # Base class for all ITU identifiers
      class Base < Lutaml::Model::Serializable
        attribute :sector, PubidNew::Itu::Components::Sector
        attribute :series, PubidNew::Itu::Components::Series
        attribute :code, PubidNew::Itu::Components::Code
        attribute :date, PubidNew::Components::Date
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
