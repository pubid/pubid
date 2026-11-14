module Pubid
  module CenPfs
    class Builder
      # The type each declared token selects (feature 1); the
      # token-free type is the default class.
      TYPE_TOKENS = {
          "TR" => "TechnicalReport",
          "TS" => "TechnicalSpecification",
          "Guide" => "Guide",
          "CR" => "CenReport",
          "CWA" => "CenWorkshopAgreement",
          "ES" => "EuropeanSpecification",
          "ENV" => "EuropeanPrestandard",
          "HD" => "HarmonizationDocument",
      }.freeze

      DEFAULT_TYPE = "EuropeanNorm"

      # The declared draft stages (feature 2): code → the
      # typed-stage row the trio builds from.
      STAGES = {
        "pren" => { code: :pren, stage_code: :proposal, type_code: :en, abbr: ["prEN"] },
        "fpren" => { code: :fpren, stage_code: :final_proposal, type_code: :en, abbr: ["FprEN"] },
      }.freeze

      # The captured spelling → the serialized stage code.
      STAGE_MAP = {
          "prEN" => "pren",
          "FprEN" => "fpren",
      }.freeze

      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def self.stage_by_code(code)
        row = STAGES[code.to_s]
        return nil unless row

        ::Pubid::Components::TypedStage.new(
          code: row[:code], stage_code: row[:stage_code],
          type_code: row[:type_code], abbr: row[:abbr],
        )
      end

      def build(data)
        base = build_base_document(data)
        wrapped = wrap_supplements(base, data)
        wrap_fragment(wrapped, data)
      end

      # The document the supplements apply to. The adopted-base
      # dispatch (feature 4) calls the vendored hook at two explicit
      # points: the captured adopted run, and the hook's own implicit
      # probe — never implicitly.
      def build_base_document(data)
        return AdoptedBase.build(self, data) if data[:adopted]

        implicit = AdoptedBase.implicit(self, data)
        return implicit if implicit

        identifier = locate_identifier_klass(data).new
        assign_attributes(identifier, data)
        identifier
      end

      # The class each reference selects: the type-position token
      # first, then the publisher-position token (the publisher-type
      # faces CR/CWA/…), then the token-free default class.
      def locate_identifier_klass(data)
        token = data[:guide] || data[:type]
        token ||= data[:publisher] if TYPE_TOKENS.key?(data[:publisher].to_s)
        name = token ? TYPE_TOKENS.fetch(token.to_s, DEFAULT_TYPE) : DEFAULT_TYPE
        Identifiers.const_get(name)
      end

      # The columns, as the coded builder's cast writes them.
      def assign_attributes(identifier, data)
        if data[:year]
          identifier.date = ::Pubid::Components::Date.new(
            year: data[:year]&.to_s,
          )
        end
        identifier.number = data[:number]&.to_s
        identifier.part = data[:part]&.to_s
        identifier.version = present_string(data[:version])
        if data[:publisher]
          identifier.publisher = ::Pubid::Components::Publisher.new(body: data[:publisher].to_s)
        end
        copubs = Array(data[:copublishers]).map do |row|
          value = row[:copublisher] || row["copublisher"]
          ::Pubid::Components::Publisher.new(body: unwrap(value).to_s)
        end
        identifier.copublishers = copubs unless copubs.empty?
        type_token = data[:guide] || data[:type]
        identifier.type = ::Pubid::Components::Type.new(abbr: type_token.to_s) if type_token
        captured = data[:stage]
        return unless captured

        typed_stage = Builder.stage_by_code(STAGE_MAP.fetch(captured.to_s))
        identifier.typed_stage = typed_stage
        identifier.type = typed_stage.to_type
        identifier.stage = typed_stage.to_stage
      end

      # A capture the grammar bound as an empty string stores as nil:
      # to_hash drops the empty string, so from_hash would give nil and
      # the two identifiers would not be ==.
      def present_string(value)
        str = unwrap(value)&.to_s
        str unless str.nil? || str.empty?
      end

      # The run's internal captures bind only through the item row, so
      # unbound ones arrive as raw leaves — a Parsanol::Slice or a
      # {value:, offset: ...} span. Unwrap the captured value.
      def unwrap(capture)
        return capture.content if capture.is_a?(Parsanol::Slice)
        return capture[:value] if capture.is_a?(Hash) && capture.key?(:value)

        capture
      end

      # The wrapper classes by kind face: the run's dispatch.
      SUPPLEMENT_WRAPPERS = {
        "A" => Identifiers::Amendment,
        "AC" => Identifiers::Corrigendum,
      }.freeze

      def wrap_supplements(base, data)
        rows = Array(data[:supplements])
        return base if rows.empty?

        items = rows.map do |row|
          inner = row[:supplement] || row["supplement"] || {}
          inner = inner.values.first if inner.values.all?(Hash)
          inner
        end
        if items.any? { |item| item[:supplements_plus] || item["supplements_plus"] }
          members = items.map { |item| supplement_from(item) }
          Identifiers::ConsolidatedIdentifier.new(identifiers: [base] + members)
        else
          supplement_from(items.first, base: base)
        end
      end

      def supplement_from(item, base: nil)
        kind = unwrap(item[:supplement_kind] || item["supplement_kind"])
        number = unwrap(item[:supplement_number] || item["supplement_number"])
        attrs = {}
        attrs[:base] = base if base
        attrs[:number] = present_string(number)
        attrs[:year] = present_string(unwrap(item[:supplements_year] || item["supplements_year"]))
        attrs[:month] = present_string(unwrap(item[:supplements_month] || item["supplements_month"]))
        SUPPLEMENT_WRAPPERS.fetch(kind.to_s).new(**attrs)
      end

      def wrap_fragment(identifier, data)
        return identifier unless data[:fragment_number]

        Identifiers::Fragment.new(
          number: unwrap(data[:fragment_number]).to_s, base: identifier,
        )
      end
    end
  end

  Pubid::CenPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
end
