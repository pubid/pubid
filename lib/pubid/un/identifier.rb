# frozen_string_literal: true

module Pubid
  module Un
    class Identifier < ::Pubid::Identifier
      attribute :path, :string, collection: true, default: []
      attribute :number, :string

      UN_TYPE_MAP = {
        "pubid:un:document" => "Pubid::Un::Identifiers::Document",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: UN_TYPE_MAP
        map "path", to: :path
        map "number", to: :number
      end

      PUBLISHER = "UN"

      def to_s(**opts)
        render(format: :human, **opts)
      end

      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse UN identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
