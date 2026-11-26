# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # VAP (Version/Compilation) Identifier
      # Single Responsibility: Wraps another identifier with VAP type suffix
      # Examples: "IEC 61666:2010+AMD1:2021 CSV"
      class VapIdentifier < Identifier
        attribute :base, Identifier, polymorphic: true
        # One or more VAP codes (e.g. ["CSV"] or ["EXV", "CMV"]). Plain strings.
        attribute :vap, :string, collection: true
        attribute :edition, ::Pubid::Components::Edition, default: -> {}

        # number/date/publisher/stage are delegated to base, so
        # serialize the wrapped identifier under "base" plus the vap array; the
        # common fields live inside "base", not at the top level.
        include Pubid::Iec::DelegatedFieldSuppression

        key_value do
          map "base", with: { to: :base_to_kv, from: :base_from_kv }
          map "vap", to: :vap, render_default: false
        end

        def base_to_kv(model, doc)
          base = model.base
          return unless base

          doc.add_child(Lutaml::KeyValue::DataModel::Element.new("base",
                                                                 base.to_hash))
        end

        def base_from_kv(model, value)
          model.base = ::Pubid::Iec::Identifier.from_hash(value) if value
        end

        # VAP types mapping
        TYPE_MAP = {
          "CSV" => "Consolidated version (with Supplements)",
          "CMV" => "Compiled Maintenance Version",
          "RLV" => "Redline Version (shows changes)",
          "SER" => "Serial version",
        }.freeze

        # Delegate common attributes to base
        def publisher
          base&.publisher
        end

        def copublishers
          base&.copublishers
        end

        def code
          base&.code
        end

        def number
          base&.number
        end

        def date
          base&.date
        end

        def stage
          base&.stage
        end

        def typed_stage
          base&.typed_stage
        end

        # The wrapped document the VAP record is a view of (pubid#580):
        # the peel lets a dated base query resolve the edition through
        # the wrapper's relational predicates.
        def base_document
          base&.base_document || base
        end

        # MR string: the wrapped chain's MR with the VAP code (or codes —
        # the multi-deliverable face prints `EXV-CMV`) appended as the final
        # segment. Without it the VAP rendered the generic flat slug through
        # its delegated `number`, which dropped the part and shared one slug
        # with the bare base document (`IEC 60601-1:2005+AMD1:2012 CSV`
        # keyed `iec.60601.2005`, the same slug as `IEC 60601-2:2005+AMD1:
        # 2012 CSV` and — for a part-less base — the base itself). The
        # corrigendum-over-VAP face (`CSV/COR1:2014`) composes on top of
        # this, because the MrString renderer recurses into `base`.
        def to_mr_string
          head = base&.to_mr_string
          return "" if head.nil? || head.empty?

          codes = vap_codes
          codes.empty? ? head : [head, codes].join(Pubid::Renderers::MrString::SEPARATOR_SUPPLEMENT)
        end

        private

        # The deliverable codes, lowercased and joined — the multi-code face
        # prints `EXV-CMV`, so the slug segment reads `exv-cmv`.
        def vap_codes
          Array(vap).filter_map do |code|
            word = code.to_s.downcase.strip
            word unless word.empty?
          end.join("-")
        end
      end
    end
  end
end
