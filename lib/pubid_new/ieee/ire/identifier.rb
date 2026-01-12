# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/code"

module PubidNew
  module Ieee
    module Ire
      # Base class for IRE identifiers
      # IRE (Institute of Radio Engineers): 1912-1963
      class Identifier < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "IRE" }
        attribute :type, :string # "Trans.", "Standard", "Std"
        attribute :number, Components::Code
        attribute :year, :integer

        def initialize(**args)
          super()

          # Handle number as string or Code object
          if args[:number].is_a?(String)
            self.number = Components::Code.parse(args[:number])
          elsif args[:number]
            self.number = args[:number]
          end

          # Set other attributes
          args.each do |key, value|
            next if key == :number

            send("#{key}=", value) if respond_to?("#{key}=")
          end
        end

        # Parse IRE identifier string
        def self.parse(input)
          require_relative "parser"
          require_relative "builder"

          parsed = Parser.new.parse(input)
          builder = Builder.new
          builder.build(parsed)
        end

        def to_s
          parts = []
          # Year comes FIRST in IRE format - render as 2-digit short year
          if year
            short_year = year >= 1900 && year <= 1999 ? year - 1900 : year
            parts << short_year.to_s
          end
          parts << publisher
          parts << type if type
          parts << number.to_s if number
          parts.join(" ")
        end
      end
    end
  end
end
