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

        def publisher
          "ETSI"
        end

        def to_s
          result = "#{publisher} #{type} #{code}"
          result += " #{version} (#{date.year}-#{date.month.to_s.rjust(2, '0')})"
          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          type == other.type &&
            code == other.code &&
            version == other.version &&
            date == other.date
        end
      end
    end
  end
end