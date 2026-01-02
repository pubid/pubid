# frozen_string_literal: true

require "lutaml/model"
require_relative "components/publisher"
require_relative "components/code"
require_relative "components/date"
require_relative "components/type"
require_relative "../components/stage"
require_relative "../components/typed_stage"

module PubidNew
  module Bsi
    class SingleIdentifier < Lutaml::Model::Serializable
      attribute :publisher, Bsi::Components::Publisher, default: -> { Bsi::Components::Publisher.new(body: "BS") }
      attribute :number, Bsi::Components::Code
      attribute :part, Bsi::Components::Code
      attribute :subpart, Bsi::Components::Code
      attribute :second_number, Bsi::Components::Code  # For collections like PAS 2035/2030
      attribute :date, Bsi::Components::Date
      attribute :stage, PubidNew::Components::Stage
      attribute :type, Bsi::Components::Type
      attribute :typed_stage, PubidNew::Components::TypedStage
      attribute :edition, :string
      attribute :month, :integer
      attribute :expert_commentary, :boolean, default: -> { false }
      attribute :tracked_changes, :boolean, default: -> { false }
      attribute :pdf, :boolean, default: -> { false }
      attribute :translation_lang, :string
      attribute :translation_upper, :string

      def to_s(lang: :en, lang_single: false)
        parts = []

        # Get type short name
        type_short = if type.is_a?(Bsi::Components::Type)
                       type.abbr
                     elsif self.class.respond_to?(:type)
                       self.class.type[:short]
                     else
                       "BS"  # Default
                     end

        # Stage prefix (Draft BS) OR type as publisher
        if typed_stage && typed_stage.abbr && typed_stage.abbr.first != type_short
          # Use full typed_stage abbreviation for stages
          parts << typed_stage.abbr.first
        elsif stage && stage.respond_to?(:abbr)
          parts << stage.abbr
        elsif type.is_a?(Bsi::Components::Type) && type.abbr != "BS"
          parts << type.abbr
        else
          parts << type_short
        end

        # Number with part/subpart or collection
        if number
          number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s

          # Collection (second number with slash)
          if second_number
            second_val = second_number.respond_to?(:value) ? second_number.value : second_number
            number_str += "/#{second_val}"
          end

          # Part and subpart
          if part
            part_val = part.respond_to?(:value) ? part.value : part
            number_str += "-#{part_val}"
          end
          if subpart
            subpart_val = subpart.respond_to?(:value) ? subpart.value : subpart
            number_str += "-#{subpart_val}"
          end
          parts << number_str
        end

        result = parts.join(" ")

        # Date
        if date
          year_val = date.respond_to?(:year) ? date.year : date.to_i
          result += ":#{year_val}"
          # Month if present
          result += "-#{format('%02d', month)}" if month
        end

        # Edition
        result += " v#{edition}" if edition

        # Tracked Changes
        result += " - TC" if tracked_changes

        # Translation
        if translation_lang
          result += " (#{translation_lang})"
        elsif translation_upper
          result += " (#{translation_upper})"
        end

        # PDF
        result += " PDF" if pdf

        result
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)

        # Compare by number first
        num_cmp = number.to_s <=> other.number.to_s
        return num_cmp unless num_cmp.zero?

        # Then by part
        part_cmp = (part || Components::Code.new(value: "0")).to_s <=> (other.part || Components::Code.new(value: "0")).to_s
        return part_cmp unless part_cmp.zero?

        # Then by date
        if date && other.date
          date.to_s <=> other.date.to_s
        elsif date
          1
        elsif other.date
          -1
        else
          0
        end
      end
    end
  end
end