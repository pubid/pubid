# frozen_string_literal: true

module Pubid
  module Cie
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "cie"]

        special_type = special_identifier_type_component
        parts << special_type if special_type

        if maybe(:s_prefix)
          parts << "s"
        end

        parts << publisher_component

        if identifier.code
          parts << identifier.code.to_s
        end

        year = extract_year
        parts << year.to_s if year

        language = maybe(:language)
        if language
          if language&.code
            parts << language.code.to_s.downcase
            if language&.format
              parts << language.format.to_s.downcase
            end
          else
            parts << language.to_s.downcase
          end
        end

        stage = maybe(:stage)
        parts << stage.to_s.downcase if stage

        date_separator = maybe(:date_separator)
        parts << "sep.#{date_separator}" if date_separator

        iec_identifier = maybe(:iec_identifier)
        parts << "iec.#{iec_identifier}" if iec_identifier

        iso_reference = maybe(:iso_reference)
        parts << "iso.#{iso_reference}" if iso_reference

        doc_type = maybe(:doc_type)
        parts << "doctype.#{doc_type}" if doc_type

        identifiers_string = maybe(:identifiers_string)
        parts << "bundle.#{identifiers_string}" if identifiers_string

        bundle_number = maybe(:bundle_number)
        parts << "tut-bundle.#{bundle_number}" if bundle_number

        languages = maybe(:languages)
        if languages&.any?
          lang_codes = languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      private

      def extract_year
        year = maybe(:year)
        return year if year

        date = identifier.date
        if date
          return date.year
        end

        nil
      end

      def special_identifier_type_component
        return nil unless identifier.class

        class_name = identifier.class.name.to_s
        case class_name
        when /DualPublished/
          "dual-pub"
        when /Identical/
          "identical"
        when /JointPublished/
          "joint-pub"
        when /Bundle$/
          "bundle"
        when /TutorialBundle/
          "tut-bundle"
        end
      end

      def publisher_component
        pub = "cie"

        if identifier.publisher
          p = identifier.publisher.to_s
          pub = p.to_s.downcase
        end

        copublisher = maybe(:copublisher)
        if copublisher
          cp = copublisher.to_s
          pub = "#{pub}-#{cp.to_s.downcase}"
        else
          copubs = maybe(:copublishers)
          if copubs&.any?
            cp = copubs.map(&:to_s)
            pub = "#{pub}-#{cp.join('-').downcase}"
          end
        end

        pub
      end
    end
  end
end
