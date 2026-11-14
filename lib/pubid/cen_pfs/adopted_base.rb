# frozen_string_literal: true

module Pubid
  module CenPfs
    # The adopted-base dispatch hook (pubid-grammar#121 feature 4, the §4
    # coded escape hatch). The generated builder calls this module at two
    # explicit points — the captured adopted run, and the implicit probe —
    # and this module owns the value-dependent dispatch the declaration
    # cannot carry:
    #
    #   * the adopted string parses with the owning scheme's flavor
    #     ("ISO/IEC" and "ISO" leads through Pubid::Iso, "IEC" through
    #     Pubid::Iec);
    #   * an ENV-prefixed adoption switches the class to the prestandard
    #     (the coded ENV branch), the publisher staying ENV;
    #   * an EN with a bare number in the IEC range (60000-79999) adopts
    #     the corresponding IEC standard implicitly — the ISO-only range
    #     is intentionally NOT mapped (too many real CEN publications
    #     would change type; pubid#249).
    module AdoptedBase
      IMPLICIT_IEC_RANGE = (60_000..79_999)

      class << self
        # The adoption identifier the captured run builds, or nil when the
        # run names no known flavor (the caller surfaces the parse error).
        def build(builder, data)
          adopted_str = builder.unwrap(data[:adopted])&.to_s&.strip
          return nil unless adopted_str && !adopted_str.empty?

          adopted_id = parse_adopted(adopted_str)
          publisher = builder.unwrap(data[:publisher])&.to_s
          return env_adopted(adopted_id) if publisher == "ENV"

          attrs = adoption_attrs(builder, data, adopted_id, publisher)
          Identifiers::AdoptedEuropeanNorm.new(**attrs)
        end

        # The implicit adoption probe: an EN with a bare IEC-range number,
        # no parts and no supplements, adopts the corresponding IEC
        # standard (the coded builder's own guard). nil otherwise.
        def implicit(builder, data)
          return nil unless implicit_adoption?(builder, data)

          number = builder.unwrap(data[:number])&.to_s&.strip
          return nil unless number&.match?(/\A\d{1,6}\z/)
          return nil unless IMPLICIT_IEC_RANGE.cover?(number.to_i)

          Identifiers::AdoptedEuropeanNorm.new(
            adopted: Pubid::Iec.parse("IEC #{number}"),
          )
        end

        private

        # The ENV adoption switch: the prestandard wraps the adopted
        # document, its publisher staying ENV.
        def env_adopted(adopted_id)
          Identifiers::EuropeanPrestandard.new(
            publisher: ::Pubid::Components::Publisher.new(body: "ENV"),
            adopted: adopted_id,
          )
        end

        # The adoption's own columns: the draft stage rides the CEN
        # adoption ("prEN ISO 1234:2020"), the publisher face, and the
        # copublishers.
        def adoption_attrs(builder, data, adopted_id, publisher)
          attrs = { adopted: adopted_id }
          attrs.merge!(stage_attrs(builder, data))
          attrs[:publisher] =
            ::Pubid::Components::Publisher.new(body: publisher) if publisher
          copubs = Array(data[:copublishers]).map do |row|
            value = builder.unwrap(row[:copublisher] || row["copublisher"])
            ::Pubid::Components::Publisher.new(body: value.to_s)
          end
          attrs[:copublishers] = copubs unless copubs.empty?
          attrs
        end

        def stage_attrs(builder, data)
          stage = builder.unwrap(data[:stage])
          return {} unless stage

          typed_stage = ::Pubid::CenPfs::Builder.stage_by_code(
            ::Pubid::CenPfs::Builder::STAGE_MAP.fetch(stage.to_s),
          )
          { typed_stage: typed_stage, type: typed_stage.to_type,
            stage: typed_stage.to_stage }
        end

        # The coded guard: the EN publisher alone, no copublishers, no
        # parts, no supplements — only then may the number imply adoption.
        def implicit_adoption?(builder, data)
          builder.unwrap(data[:publisher])&.to_s == "EN" &&
            Array(data[:copublishers]).none? &&
            builder.unwrap(data[:part]).nil? &&
            Array(data[:supplements]).none?
        end

        # "EN ISO 13485:2016/Amd 1:2016" parses the ADOPTED string with the
        # ISO flavor (its amendment spelling included); an IEC lead token
        # parses with the IEC flavor. CISPR stays unparsed (the coded
        # builder's own boundary).
        def parse_adopted(adopted_str)
          if adopted_str.start_with?("IEC")
            Pubid::Iec.parse(adopted_str)
          elsif adopted_str.start_with?("ISO")
            Pubid::Iso.parse(adopted_str)
          end
        end
      end
    end
  end
end
