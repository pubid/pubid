# frozen_string_literal: true

require "lutaml/model"
require_relative "../../components/date"
require_relative "../components/code"
require_relative "../components/version"

module PubidNew
  module Etsi
    module Identifiers
      # Base class for all ETSI identifiers
      class Base < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :code, PubidNew::Etsi::Components::Code
        attribute :version, PubidNew::Etsi::Components::Version
        attribute :date, PubidNew::Components::Date
        attribute :amendments, :integer, collection: true  # For /A1, /A2, etc.
        attribute :corrigenda, :integer, collection: true  # For /C1, /C2, etc.

        def publisher
          "ETSI"
        end

        def to_s
          result = "#{publisher} #{type} #{code}"

          # Add amendments
          if amendments&.any?
            amendments.each { |num| result += "/A#{num}" }
          end

          # Add corrigenda
          if corrigenda&.any?
            corrigenda.each { |num| result += "/C#{num}" }
          end

          result += " #{version} (#{date.year}-#{date.month.to_s.rjust(2, '0')})"
          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          type == other.type &&
            code == other.code &&
            version == other.version &&
            date == other.date &&
            amendments == other.amendments &&
            corrigenda == other.corrigenda
        end
      end
    end
  end
end