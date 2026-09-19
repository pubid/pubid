# frozen_string_literal: true

module Pubid
  module Ashrae
    class UrnGenerator < Pubid::UrnGenerator::Base
      # A supplement carries no number of its own — only the two
      # single-document leaves declare one — so reach it through #root, which
      # walks `base` to the standard the supplement attaches to. #generate
      # sends a supplement with a `base` to #supplement_urn, so only a
      # supplement without a `base` reaches this fallback.
      def urn_number
        num = identifier.number || identifier.root.number
        return nil if num.nil? || num.to_s.empty?

        num.to_s
      end

      # ASHRAE keeps the edition of a document in its own `year` string. The
      # base hook reads the inherited `date` first, which on an Errata holds
      # the date of the erratum — a different thing from the edition year of
      # the standard, and misleading in the year slot. Read `year` only.
      def urn_year
        identifier.year&.to_s
      end

      def urn_suffix
        identifier.suffix&.to_s&.downcase
      end

      def urn_amendment
        "amd.#{identifier.amendment}" if identifier.amendment
      end

      def urn_reaffirmed
        "reaff.#{identifier.reaffirmed}" if identifier.reaffirmed
      end

      def urn_copublisher
        "copub.#{identifier.copublisher.to_s.downcase}" if identifier.copublisher
      end

      def generate
        supplement? ? supplement_urn : document_urn
      end

      private

      def supplement?
        identifier.is_a?(SupplementIdentifier) && !identifier.base.nil?
      end

      def document_urn
        parts = ["urn", "ashrae"]
        parts << urn_number if urn_number
        parts << urn_year if urn_year
        parts << identifier.type.to_s.downcase if identifier.type
        parts << urn_suffix if urn_suffix
        parts << urn_amendment if urn_amendment
        parts << urn_reaffirmed if urn_reaffirmed
        parts << urn_copublisher if urn_copublisher

        parts[1] = identifier.publisher.to_s.downcase if identifier.publisher

        parts.join(":")
      end

      # A supplement keeps the year, the type and the suffix on its `base`.
      # Its URN is the URN of that base plus one segment that names the
      # supplement ("add.e", "errata.2008-10-10", "interp"). The segment is
      # the marker the MR slug uses, so the two surfaces cannot drift apart.
      # Without this, every supplement of one document had the same bare
      # "urn:ashrae:<number>" (hand-off ashrae-supplement-urn-collapse).
      def supplement_urn
        marker = identifier.mr_supplement_suffix
        [self.class.new(identifier.base).generate, marker]
          .reject { |part| part.nil? || part.empty? }.join(":")
      end
    end
  end
end
