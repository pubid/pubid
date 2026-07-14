# frozen_string_literal: true

module Pubid
  module Ogc
    # Turns the parse tree into an Ogc::Identifiers::Document. OGC has a single
    # document type, so there is no type dispatch.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        Identifiers::Document.new(
          year: data[:year].to_s,
          number: data[:number].to_s,
          revision: normalize_revision(data[:revision]),
        )
      end

      private

      # Normalize the revision suffix to its canonical lowercased form (the
      # shape the relaton index stores, e.g. "R1" -> "r1"). nil when there is
      # no revision.
      def normalize_revision(revision)
        return nil if revision.nil?

        normalized = revision.to_s.strip.downcase
        normalized.empty? ? nil : normalized
      end
    end
  end
end
