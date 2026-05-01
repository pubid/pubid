# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "identifiers"
require_relative "components/sector"
require_relative "components/series"
require_relative "components/code"

module Pubid
  module Itu
    module Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ITU identifier '#{identifier}': #{e.message}"
      end

      # Factory mirroring v1's Pubid::Itu::Identifier.create API. The v1 form
      # accepts a `type:` discriminator plus attribute kwargs; this v2
      # implementation supports the subset needed by metanorma-itu PR #497:
      #   * type: :annex — builds Identifiers::Annex
      #   * series: "OB" (with no type:) — builds Identifiers::SpecialPublication
      def self.create(type: nil, **kwargs)
        case type
        when :annex
          Identifiers::Annex.new(**kwargs)
        when nil
          if kwargs[:series].to_s == "OB"
            create_special_publication(**kwargs)
          else
            raise ArgumentError, "Identifier.create without :type requires series: 'OB'"
          end
        else
          raise ArgumentError, "Unsupported type for Identifier.create: #{type.inspect}"
        end
      end

      def self.create_special_publication(number:, series: "OB", date: nil, language: nil)
        Identifiers::SpecialPublication.new(
          series: Components::Series.new(series: series.to_s),
          code: Components::Code.new(number: number.to_s),
          date: date,
          language: language&.to_s,
        )
      end
    end
  end
end
