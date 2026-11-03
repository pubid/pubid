# frozen_string_literal: true

module Pubid
  module Iho
    # Build IHO identifier objects from the grammar's typed bound map.
    #
    # Parse goes through {Pubid::Parg::Model.bound} — the artifact's
    # `bindings identifier` block delivers every component as an
    # attribute-named scalar (type, number, part, annex, appendix,
    # appendix_subnumber, supplement, edition, edition_shorthand, year,
    # volume, issue) — so the builder only dispatches the series letter
    # to its concrete class and resolves the one grammar-level alias:
    # the S-100 "v1"/"v5.1" edition shorthand pads to the official
    # dotted x.y.z edition ("1" -> "1.0.0", "5.1" -> "5.1.0").
    class Builder
      ATTRIBUTES = %i[number appendix appendix_subnumber part annex
                      supplement year volume issue
                      part_edition part_year supplement_edition
                      supplement_year annex_edition annex_year
                      appendix_edition appendix_year volume_edition
                      volume_year].freeze
      # The independently-publishable components' own editions; the
      # base edition context is mutually exclusive with them (owner
      # ruling on the two publication modes).
      COMPONENT_EDITIONS = %i[part_edition supplement_edition annex_edition
                              appendix_edition volume_edition].freeze

      def build(parsed)
        hash = parsed.is_a?(Array) ? parsed.reduce({}, :merge) : parsed
        attrs = stringified_attrs(hash)
        assert_edition_mode!(attrs)
        klass = Pubid::Iho.identifier_klass_for_type_letter(stringify(hash[:type]))
        klass.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      # The two publication modes are mutually exclusive: an identifier
      # is either within-edition (a base edition its components ride) or
      # separately-published (a component carries its own edition and
      # the base is cited edition-less).
      def assert_edition_mode!(attrs)
        return unless attrs[:edition]
        return unless COMPONENT_EDITIONS.any? { |key| attrs[key] }

        owned = attrs.slice(*COMPONENT_EDITIONS).compact.keys.join(", ")
        raise ArgumentError,
              "a base edition and a component edition are mutually " \
              "exclusive: #{owned} cannot ride edition #{attrs[:edition]}"
      end

      def stringified_attrs(hash)
        attrs = ATTRIBUTES.to_h { |key| [key, stringify(hash[key])] }
        attrs[:edition] = edition_from(hash[:edition], hash[:edition_shorthand])
        attrs.compact
      end

      # The official IHO edition is the dotted x.y.z; the "v1"/"v5.1"
      # shorthand is a parse-only alias that fills the same attribute.
      def edition_from(edition, shorthand)
        return stringify(edition) if edition

        pad_edition_shorthand(shorthand)
      end

      def pad_edition_shorthand(shorthand)
        return nil if shorthand.nil?

        major, minor = stringify(shorthand).split(".")
        "#{major}.#{minor || '0'}.0"
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end

Pubid::Iho::Builder.prepend(Pubid::Builder::AllPartsWrap)
