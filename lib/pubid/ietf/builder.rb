# frozen_string_literal: true

module Pubid
  module Ietf
    # Turns the Parser's parse tree into a concrete identifier object, choosing
    # the class from which fields are present.
    class Builder
      SUBSERIES_CLASSES = {
        "BCP" => "Bcp",
        "STD" => "Std",
        "FYI" => "Fyi",
      }.freeze

      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        if data.key?(:draft_rest)
          build_draft(data)
        elsif data[:series]
          build_subseries(data)
        else
          build_rfc(data)
        end
      end

      private

      def build_rfc(data)
        Identifiers::Rfc.new(number: data[:number].to_s)
      end

      def build_subseries(data)
        series = data[:series].to_s
        klass = Identifiers.const_get(SUBSERIES_CLASSES.fetch(series))
        klass.new(series: series, number: data[:number].to_s)
      end

      def build_draft(data)
        full = "draft-#{data[:draft_rest]}"
        name, version = split_draft_version(full)
        Identifiers::InternetDraft.new(name: name, version: version)
      end

      # An Internet-Draft version is a trailing "-NN" of *exactly* two digits at
      # the very end of the slug. A three-digit topic tail (e.g. "...-256") is
      # NOT a version: there the char before the last two digits is itself a
      # digit, not "-", so the guard below leaves it in the name. This also
      # means a (non-existent in practice) revision >= 100 would be read as part
      # of the name — IETF drafts are always two-digit-versioned, so that case
      # never arises. Either way the printed string round-trips exactly.
      def split_draft_version(full)
        if full.length > 3 && full[-3] == "-" && full[-2..].match?(/\A\d\d\z/)
          [full[0...-3], full[-2..]]
        else
          [full, nil]
        end
      end
    end
  end
end
