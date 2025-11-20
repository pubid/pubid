# frozen_string_literal: true

require "lutaml/model"
require_relative "../../components/date"
require_relative "../components/publisher"
require_relative "../components/code"

module PubidNew
  module Iso
    module Identifiers
      # Base class for ISO identifiers
      class Base < Lutaml::Model::Serializable
        attribute :publisher, PubidNew::Iso::Components::Publisher
        attribute :type, :string  # TR, TS, Guide, etc.
        attribute :code, PubidNew::Iso::Components::Code
        attribute :year, :integer
        attribute :stage, :string  # WD, CD, DIS, FDIS, etc.
        attribute :iteration, :integer
        attribute :edition, :integer
        attribute :language, :string

        def to_s
          result = publisher.to_s

          # Add stage if present
          if stage
            result += publisher.has_copublisher? ? " #{stage}" : "/#{stage}"
          end

          # Add type if present (TR, TS, Guide)
          if type && type != "IS"
            sep = (stage || publisher.has_copublisher?) ? " " : "/"
            result += "#{sep}#{type}"
          end

          # Add code
          result += " #{code}"

          # Add iteration if present
          result += ".#{iteration}" if iteration

          # Add year
          result += ":#{year}" if year

          # Add language
          result += "(#{language})" if language

          result
        end

        def ==(other)
          return false unless other.is_a?(Base)

          publisher == other.publisher &&
            type == other.type &&
            code == other.code &&
            year == other.year &&
            stage == other.stage
        end
      end
    end
  end
end