# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Edition component for NIST publications per nist-pubid-spec.md
      # Format: <edition-type><edition-id>[.<additional-text>]
      # Types: "-" (historical), "e" (edition), "r" (revision)
      # Edition ID can be: number ("2") OR year ("2021")
      # Additional text: Text AFTER "rev" prefix (WITHOUT "rev")
      #
      # SEMANTICS:
      # - "e" or "edition" = edition (can be number or year or month+year)
      # - "r" or "rev" or "revision" or "v" or "version" = revision (can be number or year or month+year)
      # - If BOTH edition AND revision in same identifier:
      #   * Type is "e" (edition takes precedence)
      #   * ID is the edition value
      #   * additional_text is the revision part (WITHOUT "rev" prefix)
      #   * Renders with DOT separator: e2.June1908
      #
      # Examples:
      #   Edition.new(type: "e", id: "2").to_s                              # => "e2"
      #   Edition.new(type: "e", id: "2", additional_text: "June1908").to_s # => "e2.June1908"
      #   Edition.new(type: "e", id: "2", additional_text: "1908").to_s     # => "e2.1908"
      #   Edition.new(type: "r", id: "1963").to_s                           # => "r1963"
      #   Edition.new(type: "r", id: "5").to_s                              # => "r5"
      class Edition < Lutaml::Model::Serializable
        attribute :type, :string            # "-", "e", or "r"
        attribute :id, :string              # Edition ID (number or year)
        attribute :additional_text, :string # Text after "rev" (WITHOUT "rev" prefix)

        # Render edition in specified format
        # @param format [:short, :mr, :long, :abbrev] The output format
        # @return [String] The formatted edition representation
        def to_s(format = :short)
          case format
          when :short, :mr
            build_short_format
          when :long
            build_long_format
          when :abbrev
            build_short_format
          else
            build_short_format
          end
        end

        private

        # Build short format: "e2", "e2.June1908", "e2.1908", "r1963", "-April1909"
        def build_short_format
          result = "#{type}#{id}"

          if additional_text && !additional_text.empty?
            # For historical editions ("-") with month names, NO dot separator
            # Pattern: "-April1909" not "-.April1909"
            if type == "-" && additional_text.match?(/^[A-Z][a-z]+\d{4}$/)
              result = "-#{additional_text}"
            else
              # Regular editions use DOT separator for additional text
              result += ".#{additional_text}"
            end
          end

          result
        end

        # Build long format: "Edition 2021", "Revision 5", etc.
        def build_long_format
          case type
          when "e"
            "Edition #{id}"
          when "r"
            "Revision #{id}"
          when "-"
            # Historical precedent - render as dash-number
            "-#{id}"
          else
            "#{type}#{id}"
          end
        end
      end
    end
  end
end