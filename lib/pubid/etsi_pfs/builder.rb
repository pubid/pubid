module Pubid
  module EtsiPfs
    class Builder
      # The wrapper classes by kind face: the run's dispatch.
      SUPPLEMENT_WRAPPERS = {
        "A" => Identifiers::Amendment,
        "C" => Identifiers::Corrigendum,
      }.freeze

      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        identifier = Identifiers::Standard.new(
          type: data[:type],
          number: data[:number],
          minor: data[:minor],
          parts: build_parts(data),
          version: data[:version] || data[:edition],
          is_edition: !data[:edition].nil?,
          year: data[:year],
          month: data[:month],
        )
        run = Array(data[:supplements])
        run.each do |row|
          item = row[:supplement] || row["supplement"] || {}
          kind = unwrap(item[:supplement_kind] || item["supplement_kind"])
          identifier = SUPPLEMENT_WRAPPERS.fetch(kind).new(
            number: unwrap(item[:supplement_number] || item["supplement_number"]).to_i,
            base: identifier,
          )
        end
        identifier
      end

      # The run's internal captures bind only through the item row
      # (the cen_cenelec precedent), so unbound ones arrive as raw
      # leaves — a Parsanol::Slice or a {value:, offset: ...} span.
      # Unwrap the captured value.
      def unwrap(capture)
        return capture.content if capture.is_a?(Parsanol::Slice)
        return capture[:value] if capture.is_a?(Hash) && capture.key?(:value)

        capture
      end

      # The parts column from its bound item rows.
      def build_parts(data)
        Array(data[:parts]).map do |row|
          row[:part] || row["part"]
        end.compact
      end
    end
  end

  Pubid::EtsiPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
end
