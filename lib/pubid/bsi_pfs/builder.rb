module Pubid
  module BsiPfs
    class Builder
      # The type each declared token selects (feature 1); the
      # token-free type is the default class.
      TYPE_TOKENS = {
          "PAS" => "PubliclyAvailableSpecification",
          "PD" => "PublishedDocument",
          "DD" => "DraftDocument",
          "TS" => "TechnicalSpecification",
          "AMD" => "StandaloneAmendment",
      }.freeze

      DEFAULT_TYPE = "BritishStandard"

      # The declared draft stages (feature 2): code → the
      # typed-stage row the trio builds from.
      STAGES = {

      }.freeze

      # The captured spelling → the serialized stage code.
      STAGE_MAP = {

      }.freeze

      # The designation trios (the typed trio's declaration): the
      # token that selected the class is the designation face, not
      # a publisher — the column keeps the class default and the
      # identifier carries the stage entry's type/stage/typed_stage
      # (the coded builder's cast). A face-only designation
      # (designation: face) joins DESIGNATION_TOKENS without a row
      # here — nothing serializes beyond _type.
      DESIGNATION_STAGES = {
        "PAS" => { code: "pubpas", stage_code: "published", type_code: "pas", abbr: ["PAS"], name: "Publicly Available Specification", harmonized_stages: ["60.00", "60.60"] },
        "PD" => { code: "pubpd", stage_code: "published", type_code: "pd", abbr: ["PD"], name: "Published Document", harmonized_stages: ["60.00", "60.60"] },
        "DD" => { code: "pubdd", stage_code: "published", type_code: "dd", abbr: ["DD"], name: "Draft Document", harmonized_stages: ["60.00", "60.60"] },
        "TS" => { code: "pubts", stage_code: "published", type_code: "ts", abbr: ["TS"], name: "Technical Specification", harmonized_stages: ["60.00", "60.60"] },
      }.freeze

      # Every designation token (trio and face-only): the token
      # that selected the class never lands on the publisher
      # column — the column keeps the organization default.
      DESIGNATION_TOKENS = {
        "PAS" => true,
        "PD" => true,
        "DD" => true,
        "TS" => true,
        "AMD" => true,
      }.freeze

      # The model column the adopted document lands on (the vendored
      # hook's wrapper slot) and the declared edition face, if any.
      ADOPTED_ATTRIBUTE = "base"
      ADOPTED_EDITION_FACE = "ED"

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
        wrapped
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
        # A designation token selects the class but is not a publisher:
        # the column keeps the class default (the organization's).
        if data[:publisher] && !DESIGNATION_TOKENS.key?(data[:publisher].to_s)
          identifier.publisher = ::Pubid::Components::Publisher.new(body: data[:publisher].to_s)
        end
        copubs = Array(data[:copublishers]).map do |row|
          value = row[:copublisher] || row["copublisher"]
          ::Pubid::Components::Publisher.new(body: unwrap(value).to_s)
        end
        identifier.copublishers = copubs unless copubs.empty?
        type_token = data[:guide] || data[:type]
        identifier.type = ::Pubid::Components::Type.new(abbr: type_token.to_s) if type_token
        # The typed trio (the designation's stage entry): type, stage
        # and typed_stage carry the registry row — the wire keys the
        # coded flavor serializes.
        if (row = DESIGNATION_STAGES[data[:publisher].to_s])
          typed_stage = ::Pubid::Components::TypedStage.new(
            code: row[:code], stage_code: row[:stage_code],
            type_code: row[:type_code], abbr: row[:abbr],
            name: row[:name], harmonized_stages: row[:harmonized_stages],
          )
          identifier.typed_stage = typed_stage
          identifier.type = typed_stage.to_type
          identifier.stage = typed_stage.to_stage
        end
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
        "C" => Identifiers::Corrigendum,
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
          # The declared marker-less bundle (the coded-BSI shape): each
          # member amends THE bundle's base document, so the members
          # carry it (the coded builder's wrap_with_consolidated).
          members = items.map { |item| supplement_from(item, base: base) }
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
        SUPPLEMENT_WRAPPERS.fetch(kind.to_s).new(**attrs)
      end
    end
  end

  Pubid::BsiPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
end
