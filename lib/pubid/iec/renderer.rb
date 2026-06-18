# frozen_string_literal: true

module Pubid
  module Iec
    # Human-readable renderer for IEC identifiers.
    #
    # Components are accessed only through `component.render(context:)`.
    #
    # Produces strings like:
    #   "IEC 60038:2009"
    #   "IEC/CD 60038"
    #   "IEC 60038:2009/AMD1:2011"
    #   "IEC/FDAM 60038-1"
    #   "IEC 60529:1989+AMD1:1999 CSV"
    #
    # The renderer is registered as the `:human` format in the IEC format
    # registry and invoked via `render(format: :human)`.
    #
    # For simple (non-wrapper) identifiers, the renderer delegates to the
    # identifier's own `publisher_portion` / `number_portion` helpers so that
    # per-type overrides (e.g. TR, TS, Guide) continue to work without
    # duplication.  Wrapper types (Consolidated, VAP, Sheet, Fragment,
    # Supplement, WorkingDocument, TestReportForm) have rendering logic
    # here because their structure differs fundamentally.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **opts)
        id = @id

        case id
        when Identifiers::ConsolidatedIdentifier
          render_consolidated(id, opts, context)
        when Identifiers::VapIdentifier
          render_vap(id, opts, context)
        when Identifiers::SheetIdentifier
          render_sheet(id, opts, context)
        when Identifiers::FragmentIdentifier
          render_fragment(id, opts, context)
        when Identifiers::WorkingDocument
          render_working_document(id, context)
        when Identifiers::TestReportForm
          render_test_report_form(id, context)
        when SupplementIdentifier
          render_supplement(id, opts, context)
        else
          render_single(id, opts, context)
        end
      end

      private

      def render_single(id, opts, context)
        parts = []
        parts << id.publisher_portion
        parts << id.number_portion

        if id.is_a?(Identifiers::Base)
          parts << " #{id.edition.render(context:)}" if id.edition&.number
        elsif opts[:with_edition] && id.edition&.number
          parts << " #{id.edition.render(context:)}"
        end

        if id.is_a?(Identifiers::Base) && id.vap_suffix
          parts << id.vap_suffix.render_with_space
        end

        if id.is_a?(Identifiers::Base) && id.database
          parts << " DB"
        end

        parts << " (all parts)" if id.all_parts

        result = parts.compact.join

        result << id.language_portion(lang_single: opts[:lang_single]) if id.languages&.any?

        result
      end

      def render_supplement(id, opts, context)
        id.ensure_base_identifier

        if id.synthetic_base?
          render_supplement_standalone(id, context)
        elsif id.base_identifier
          render_supplement_attached(id, opts, context)
        else
          render_single(id, opts, context)
        end
      end

      def render_supplement_standalone(id, context)
        parts = []

        if id.publisher
          parts << id.publisher.render(context:)
          if id.copublishers&.any?
            parts << "/#{id.copublishers.map { |c| c.render(context:) }.join('/')}"
          end
        end

        abbr = id.typed_stage.abbr.first
        number_str = id.base_identifier.number.to_s
        number_str += "-#{id.number}" if id.number
        number_str += "-#{id.subpart}" if id.subpart
        parts << "#{abbr} #{number_str}"

        result = parts.join("/")
        result += ":#{id.date.render(context:)}" if id.date
        result += " #{id.edition.render(context:)}" if id.edition&.number
        result
      end

      def render_supplement_attached(id, opts, context)
        parts = []
        parts << id.base_identifier.to_s(**opts)

        abbr = id.typed_stage.abbr.first.upcase
        supp_part = "/#{abbr}#{id.number}"
        supp_part += ":#{id.date.render(context:)}" if id.date
        parts << supp_part

        parts << " #{id.edition.render(context:)}" if id.edition&.number

        parts.join
      end

      def render_consolidated(id, opts, _context)
        id.identifiers.map.with_index do |sub_id, idx|
          if idx.zero?
            sub_id.to_s(**opts)
          elsif sub_id.is_a?(Identifiers::Amendment)
            render_consolidated_amendment(sub_id)
          elsif sub_id.is_a?(Identifiers::Corrigendum)
            render_consolidated_corrigendum(sub_id)
          else
            "+#{sub_id.to_s(**opts)}"
          end
        end.join
      end

      def render_consolidated_amendment(id)
        if id.date&.present?
          "+AMD#{id.number}:#{id.date.render}"
        else
          "+AMD#{id.number}"
        end
      end

      def render_consolidated_corrigendum(id)
        if id.date&.present?
          "+COR#{id.number}:#{id.date.render}"
        else
          "+COR#{id.number}"
        end
      end

      def render_vap(id, opts, context)
        parts = []

        parts << id.base_identifier.to_s(**opts.merge(with_edition: false))
        parts << " #{id.vap_suffix}" if id.vap_suffix
        parts << " #{id.edition.render(context:)}" if id.edition&.number

        parts.compact.join
      end

      def render_sheet(id, opts, context)
        parts = []
        parts << id.base_identifier.to_s(**opts)
        parts << "/#{id.sheet_number}"
        parts << ":#{id.year}" if id.year
        parts.join
      end

      def render_fragment(id, opts, context)
        parts = []
        parts << id.base_identifier.to_s(**opts)

        parts << if id.base_identifier.is_a?(Identifiers::Corrigendum)
                   "/FRAGC#{id.fragment_number}"
                 else
                   "/FRAG#{id.fragment_number}"
                 end

        parts << " #{id.edition.render(context:)}" if id.edition&.number

        parts.join
      end

      def render_working_document(id, context)
        if id.wp_stage
          parts = []
          if id.publisher
            parts << id.publisher.render(context:)
            if id.copublishers&.any?
              parts << "/#{id.copublishers.map { |c| c.render(context:) }.join('/')}"
            end
            parts << "/"
          end
          parts << id.wp_stage
          if id.wp_type && !id.wp_type.strip.empty?
            parts << " #{id.wp_type.strip}"
          end

          if id.number
            num_str = id.number.to_s
            num_str += "-#{id.part}" if id.part && id.part.to_s != ""
            num_str += "-#{id.subpart}" if id.subpart && id.subpart.to_s != ""
            parts << " #{num_str}"
          end

          parts << " #{id.edition.render(context:)}" if id.edition&.number
          return parts.join
        end

        parts = []
        parts << id.technical_committee if id.technical_committee

        if id.wd_number
          num_part = id.wd_number.to_s
          num_part += "(#{id.wd_language})" if id.wd_language
          parts << num_part
        end

        parts << id.wd_stage if id.wd_stage

        parts.join("/")
      end

      def render_test_report_form(id, context)
        parts = []
        parts << id.publisher_portion

        if id.cispr_identifier
          cispr_parts = []
          cispr_parts << id.cispr_identifier.publisher.render(context:)

          num_str = id.cispr_identifier.number.to_s
          num_str += "-#{id.cispr_identifier.part}" if id.cispr_identifier.part && id.cispr_identifier.part.to_s != ""
          cispr_parts << num_str

          cispr_str = cispr_parts.join(" ")
          cispr_str += ":#{id.date.render(context:)}" if id.date

          parts << " #{cispr_str}"
        else
          parts << id.number_portion
        end

        parts << id.trf_info.to_s if id.trf_info && !id.trf_info.empty?

        parts.compact.join
      end
    end
  end
end
