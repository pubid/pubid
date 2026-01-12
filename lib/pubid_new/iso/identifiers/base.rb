# frozen_string_literal: true

require "lutaml/model"
require_relative "../../identifier"
require_relative "../../components/date"
require_relative "../components/publisher"
require_relative "../components/code"

module PubidNew
  module Iso
    module Identifiers
      # Base class for ISO identifiers
      class Base < ::PubidNew::Identifier
        # Inherit all attributes from parent: number, part, date, publisher, type, stage, etc.
        # No need to redefine them here

        # Only add ISO-specific attributes if needed
        attribute :stage_iteration, ::PubidNew::Components::Code

        def to_s(lang: :en, lang_single: false, with_edition: false)
          result = publisher.to_s

          # Add stage if present
          if stage&.abbr
            result += publisher.has_copublisher? ? " #{stage.abbr}" : "/#{stage.abbr}"
          end

          # Add type if present (TR, TS, Guide, PAS, DATA, TTA, R, ISP)
          # Type should display for all non-IS types
          if type&.abbr && type.abbr != "IS"
            # Separator: space after stage or copublisher, slash otherwise
            has_prefix = stage&.abbr || publisher.has_copublisher?
            sep = has_prefix ? " " : "/"
            result += "#{sep}#{type.abbr}"
          end

          # Add number
          result += " #{number.value}" if number&.value

          # Add part (with dash)
          result += "-#{part.value}" if part&.value

          # Add subpart (with dash)
          result += "-#{subpart.value}" if subpart&.value

          # Add stage iteration if present
          result += ".#{stage_iteration.value}" if stage_iteration&.value

          # Add year
          result += ":#{date.year}" if date&.year

          # Add edition if with_edition flag is set
          result += " #{edition}" if with_edition && edition&.number

          # Add language
          if languages&.any?
            # Use the language's to_s method which handles original_code properly
            result += "(#{languages.map do |l|
              l.to_s(lang_single: lang_single)
            end.join('/')})"
          end

          result
        end

        # V1 API compatibility - tests expect .copublishers returning array of Publisher objects
        def copublishers
          return [] unless publisher.copublisher&.any?

          publisher.copublisher.map do |cp|
            ::PubidNew::Components::Publisher.new(body: cp)
          end
        end

        def ==(other)
          return false unless other.is_a?(Base)

          publisher == other.publisher &&
            type == other.type &&
            number == other.number &&
            part == other.part &&
            date == other.date &&
            stage == other.stage
        end
      end
    end
  end
end
