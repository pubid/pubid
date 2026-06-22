# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Supplement component — a structured value-object representing the
    # supplement-specific data (number, date, stage, iteration, type) of a
    # supplement identifier.
    #
    # Union shape across flavors:
    # - type:    "amd" (amendment), "cor" (corrigendum), "err" (errata),
    #            "sup" (supplement), or a flavor-specific marker.
    # - number:  bare sequence number (string preserves leading zeros, "1A"
    #            combos, etc.).
    # - date:    publication date of the supplement (Components::Date).
    # - range_end_date: end of a date range; presence of this marks the
    #            supplement as a range. (NIST/NBS uses supJan1924-Jun1925.)
    # - stage:   the stage the supplement is in (e.g., WD Amd, CD Amd).
    # - iteration: stage iteration (e.g., the ".2" in "WD.2 Amd").
    # - has_revision: "suprev" marker — supplement that itself carries a
    #            revision. (NIST-specific.)
    # - suffix:  escape hatch for patterns not yet modeled.
    #
    # Format-aware via render(context:). The human form stacks fields in the
    # order they appear in the printed supplement; the URN form joins number
    # and year with ":".
    class Supplement < Lutaml::Model::Serializable
      DEFAULT_TYPE = "sup"

      attribute :type, :string, default: -> { DEFAULT_TYPE }
      attribute :number, :string
      attribute :date, Date
      attribute :range_end_date, Date
      attribute :stage, Stage
      attribute :iteration, Components::Iteration
      attribute :has_revision, :boolean, default: false
      attribute :suffix, :string

      IDENTITY_FIELDS = %i[
        type number date range_end_date stage iteration has_revision suffix
      ].freeze

      # Fields whose presence indicates the supplement carries data.
      # `type` is excluded — it always has a value (the default "sup") but
      # doesn't mean the supplement carries content.
      CONTENT_FIELDS = %i[
        number date range_end_date stage iteration has_revision suffix
      ].freeze

      # True when the supplement carries any data. Distinguishes a present-
      # but-empty supplement (bare marker, "sup") from no supplement at all.
      def present?
        CONTENT_FIELDS.any? { |f| present_value?(public_send(f)) }
      end

      # True when this supplement spans a date range (start + end set).
      def range?
        date&.present? && range_end_date&.present?
      end

      def render(context: nil)
        return render_urn if context&.format == :urn

        render_human
      end

      def to_s(**opts)
        render(context: opts[:context])
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        identity_fields.all? { |f| public_send(f) == other.public_send(f) }
      end

      alias eql? ==

      def hash
        @hash ||= [self.class, *identity_fields.map { |f| public_send(f) }].hash
      end

      private

      def identity_fields
        IDENTITY_FIELDS
      end

      def non_empty?(value)
        return false if value.nil?

        value.is_a?(String) ? !value.empty? : value.present?
      end

      def present_value?(value)
        return value if [true, false].include?(value)
        return false if value.nil?

        value.is_a?(String) ? !value.empty? : value.present?
      end

      def number?
        non_empty?(number)
      end

      def suffix?
        non_empty?(suffix)
      end

      def stage_abbr
        return nil if stage.nil? || stage.abbr.nil?

        abbr = stage.abbr.to_s
        abbr.empty? ? nil : abbr
      end

      # Human / mr: stack fields in canonical order.
      #   "1924"            (year)
      #   "Jan1924"         (month + year)
      #   "3/1926"          (number + year)
      #   "1"               (number)
      #   "A"               (suffix)
      #   "Jan1924-Jun1925" (range)
      def render_human
        return early_marker if has_revision || suffix?
        return date_range_string if range?

        assemble_body
      end

      def early_marker
        has_revision ? "rev" : suffix.to_s
      end

      def assemble_body
        body = number_or_date_string
        body += iteration_suffix if include_iteration?
        stage_abbr ? "#{stage_abbr}#{body}" : body
      end

      def include_iteration?
        iteration && stage_abbr.nil?
      end

      def render_urn
        return "" unless present?

        [number&.to_s, date&.year&.to_s].compact.reject(&:empty?).join(":")
      end

      def iteration_suffix
        "-#{iteration.number}"
      end

      def date_range_string
        "#{date_string(date)}-#{date_string(range_end_date)}"
      end

      def number_or_date_string
        return date_string(date) unless number?

        date&.present? ? "#{number}/#{date_string(date)}" : number.to_s
      end

      # Render the body of a date fragment preserving the original month
      # abbreviation when month is a non-numeric string. Falls back to
      # Components::Date#render when month is numeric.
      def date_string(date_value)
        return "" unless date_value&.present?

        if month_abbreviation?(date_value)
          "#{date_value.month}#{date_value.year}"
        else
          date_value.render(context: nil)
        end
      end

      def month_abbreviation?(date_value)
        date_value.month && !date_value.month.match?(/^\d+$/)
      end
    end
  end
end
