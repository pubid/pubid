# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Itu
    module Components
      # ITU Code component
      # Format: [Imp]NUMBER[SUFFIX][.SUBSERIES][-PART]
      # Examples: 1234, 1234.5, 1234-1, 1234.5-2, 50bis, 8bis, Imp712, ImpOSI
      #
      # The optional "Imp" marker identifies an Implementers' Guide for the
      # series (e.g. G.Imp712, X.ImpOSI); the NUMBER that follows may be
      # digits or a short letter string.
      #
      # SUFFIX is the edition marker "bis" / "ter" / "quater" attached
      # directly to the number (e.g. X.50bis, V.8bis).
      #
      # Stays independent of Pubid::Components::Code because ITU uses
      # +subseries+ (dot-separated, flavor-specific) and +parts+
      # (dash-separated).
      class Code < Lutaml::Model::Serializable
        attribute :imp_marker, :string
        attribute :number, :string
        attribute :series_suffix, :string
        attribute :subseries, :string
        attribute :parts, :string, collection: true, default: []

        def to_s
          result = "#{imp_marker}#{number}"
          result += series_suffix.to_s if series_suffix
          result += ".#{subseries}" if subseries
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def render(context: nil)
          to_s
        end

        def ==(other)
          return false unless other.is_a?(Code)

          imp_marker == other.imp_marker &&
            number == other.number &&
            series_suffix == other.series_suffix &&
            subseries == other.subseries &&
            parts == other.parts
        end
      end
    end
  end
end
