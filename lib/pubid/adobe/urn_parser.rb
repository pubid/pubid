# frozen_string_literal: true

module Pubid
  module Adobe
    # Parses Adobe URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:adobe:tech-note:<number>
    #   urn:adobe:publication:<slug>[:v<version>]
    #
    # Examples:
    #   urn:adobe:tech-note:5014                  → Adobe Technical Note #5014
    #   urn:adobe:publication:adobe-glyph-list    → adobe-glyph-list
    #   urn:adobe:publication:adobe-japan1:v7     → adobe-japan1-7
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:adobe:".freeze

      def parse_urn(urn)
        body = strip_namespace(urn)
        parts = split_parts(body)
        namespace = parts.fetch(0)

        case namespace
        when "tech-note"
          parse_tech_note(parts)
        when "publication"
          parse_publication(parts)
        else
          raise Pubid::UrnParser::Errors::ParseError,
                "Unknown Adobe URN namespace: #{namespace.inspect} in #{urn.inspect}"
        end
      end

      private

      def strip_namespace(urn)
        unless urn.downcase.start_with?(PREFIX)
          raise Pubid::UrnParser::Errors::ParseError,
                "Invalid Adobe URN: #{urn.inspect}"
        end

        urn[PREFIX.length..]
      end

      def parse_tech_note(parts)
        number = parts.fetch(1)
        flavor_parse("Adobe Technical Note ##{number}")
      end

      def parse_publication(parts)
        slug = parts.fetch(1)
        version_seg = parts[2]
        if version_seg&.start_with?("v")
          flavor_parse("#{slug}-#{version_seg.sub(/\Av/, "")}")
        else
          flavor_parse(slug)
        end
      end

      def split_parts(body)
        body.split(":")
      end

      def flavor_parse(text)
        ::Pubid::Adobe.parse(text)
      end
    end
  end
end
