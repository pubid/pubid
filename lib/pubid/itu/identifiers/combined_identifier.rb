# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Combined (joint) recommendation — a single document published under two
      # or more series/number designations at once.
      # Format: ITU-T G.780/Y.1351         (dual)
      #         ITU-T G.780/Y.1351/Z.1362  (triple)
      #
      # The primary designation lives on the base `series`/`code`; every
      # additional designation is a Components::Designation in `combined`
      # (one for a dual form, two+ for triple).
      class CombinedIdentifier < Identifier
        include StandardSerialization

        attribute :combined, Pubid::Itu::Components::Designation,
                  collection: true, default: -> { [] }

        # Extra map merged on top of StandardSerialization: the additional
        # designations as a flat list of { series, number, subseries?, parts? }.
        key_value do
          map "combined",
              with: { to: :combined_to_kv, from: :combined_from_kv }
        end

        def combined_to_kv(model, doc)
          designations = model.combined
          return if designations.nil? || designations.empty?

          rows = designations.map do |d|
            row = { "series" => d.series&.series.to_s,
                    "number" => d.code&.number.to_s }
            row["subseries"] = d.code.subseries.to_s if d.code&.subseries
            row["parts"] = d.code.parts.map(&:to_s) if d.code&.parts&.any?
            row
          end

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("combined", rows),
          )
        end

        def combined_from_kv(model, value)
          model.combined = Array(value).map do |row|
            row = row.transform_keys(&:to_s)
            Components::Designation.new(
              series: Components::Series.new(series: row["series"].to_s),
              code: Components::Code.new(
                number: row["number"].to_s,
                subseries: row["subseries"]&.to_s,
                parts: Array(row["parts"]).map(&:to_s),
              ),
            )
          end
        end

        def to_s
          result = "#{publisher}-#{sector}"

          # Add primary series and code
          result += if series
                      " #{series}.#{code}"
                    else
                      " #{code}"
                    end

          # Add additional designations
          if combined&.any?
            result += "/#{combined.join('/')}"
          end

          # Add date if present
          if date
            result += if date.month
                        " (#{date.month}/#{date.year})"
                      else
                        " (#{date.year})"
                      end
          end

          # Add language
          result += "-#{language}" if language

          result
        end

        def ==(other)
          return false unless other.is_a?(CombinedIdentifier)

          sector == other.sector &&
            series == other.series &&
            code == other.code &&
            combined == other.combined &&
            date == other.date &&
            language == other.language
        end
      end
    end
  end
end
