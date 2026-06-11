# frozen_string_literal: true

module Pubid
  module Iec
    # Human-readable renderer for IEC identifiers.
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

        # Dispatch to type-specific renderers for wrapper types that
        # compose other identifiers.  These have unique rendering rules
        # that differ substantially from the base single-identifier pattern.
        case id
        when Identifiers::ConsolidatedIdentifier
          render_consolidated(id, opts)
        when Identifiers::VapIdentifier
          render_vap(id, opts)
        when Identifiers::SheetIdentifier
          render_sheet(id, opts)
        when Identifiers::FragmentIdentifier
          render_fragment(id, opts)
        when Identifiers::WorkingDocument
          render_working_document(id)
        when Identifiers::TestReportForm
          render_test_report_form(id)
        when SupplementIdentifier
          render_supplement(id, opts)
        else
          render_single(id, opts)
        end
      end

      private

      # ------------------------------------------------------------------
      # Core rendering for single (non-wrapper) identifiers.
      # Delegates to the identifier's own publisher_portion / number_portion.
      # ------------------------------------------------------------------

      def render_single(id, opts)
        parts = []
        parts << id.publisher_portion
        parts << id.number_portion

        # Edition: always rendered for Identifiers::Base (and subclasses);
        # for plain SingleIdentifier only when with_edition is requested.
        if id.is_a?(Identifiers::Base)
          parts << " #{id.edition}" if id.edition&.number
        elsif opts[:with_edition] && id.edition&.number
          parts << " #{id.edition}"
        end

        # VAP suffix (Identifiers::Base only)
        if id.respond_to?(:vap_suffix) && id.vap_suffix
          parts << id.vap_suffix.render_with_space
        end

        # Database flag (Identifiers::Base only)
        if id.respond_to?(:database) && id.database
          parts << " DB"
        end

        # All-parts marker
        parts << " (all parts)" if id.all_parts

        result = parts.compact.join

        # Language portion
        result << id.language_portion(lang_single: opts[:lang_single]) if id.languages&.any?

        result
      end

      # ------------------------------------------------------------------
      # Supplement rendering (Amendment, Corrigendum, ISH)
      # ------------------------------------------------------------------

      def render_supplement(id, opts)
        # Ensure synthetic base exists for standalone supplements
        id.ensure_base_identifier

        if id.synthetic_base?
          render_supplement_standalone(id)
        elsif id.base_identifier
          render_supplement_attached(id, opts)
        else
          render_single(id, opts)
        end
      end

      def render_supplement_standalone(id)
        parts = []

        # Publisher portion
        if id.publisher
          parts << id.publisher.body
          parts << "/#{id.copublishers.map(&:body).join('/')}" if id.copublishers&.any?
        end

        # Supplement type and number with part (use base number)
        abbr = id.typed_stage.abbr.first
        number_str = id.base_identifier.number.to_s
        number_str += "-#{id.number}" if id.number # supplement number
        number_str += "-#{id.subpart}" if id.subpart
        parts << "#{abbr} #{number_str}"

        result = parts.join("/")
        result += ":#{id.date.year}" if id.date
        result += " #{id.edition}" if id.edition&.number
        result
      end

      def render_supplement_attached(id, opts)
        parts = []
        parts << id.base_identifier.to_s(**opts)

        # Supplement notation: /AMD1, /COR1, /ISH1
        abbr = id.typed_stage.abbr.first.upcase
        supp_part = "/#{abbr}#{id.number}"
        supp_part += ":#{id.date.year}" if id.date
        parts << supp_part

        parts << " #{id.edition}" if id.edition&.number

        parts.join
      end

      # ------------------------------------------------------------------
      # Consolidated identifier: "IEC 60529:1989+AMD1:1999"
      # ------------------------------------------------------------------

      def render_consolidated(id, opts)
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
        if id.date&.year && !id.date.year.empty?
          "+AMD#{id.number}:#{id.date.year}"
        else
          "+AMD#{id.number}"
        end
      end

      def render_consolidated_corrigendum(id)
        if id.date&.year && !id.date.year.empty?
          "+COR#{id.number}:#{id.date.year}"
        else
          "+COR#{id.number}"
        end
      end

      # ------------------------------------------------------------------
      # VAP identifier: "IEC 61666:2010+AMD1:2021 CSV"
      # ------------------------------------------------------------------

      def render_vap(id, opts)
        parts = []

        # Render base identifier WITHOUT edition (edition goes at VAP level)
        parts << id.base_identifier.to_s(**opts.merge(with_edition: false))

        # Add VAP suffix with space
        parts << " #{id.vap_suffix}" if id.vap_suffix

        # Add edition after VAP suffix if present
        parts << " #{id.edition}" if id.edition&.number

        parts.compact.join
      end

      # ------------------------------------------------------------------
      # Sheet identifier: "IEC 60695-2-1/1:1994"
      # ------------------------------------------------------------------

      def render_sheet(id, opts)
        parts = []
        parts << id.base_identifier.to_s(**opts)
        parts << "/#{id.sheet_number}"
        parts << ":#{id.year}" if id.year
        parts.join
      end

      # ------------------------------------------------------------------
      # Fragment identifier: "IEC 60050-191/AMD2/FRAG2 ED1"
      # ------------------------------------------------------------------

      def render_fragment(id, opts)
        parts = []
        parts << id.base_identifier.to_s(**opts)

        # Add fragment notation /FRAGN or /FRAGCN depending on base type
        parts << if id.base_identifier.is_a?(Identifiers::Corrigendum)
                   "/FRAGC#{id.fragment_number}"
                 else
                   "/FRAG#{id.fragment_number}"
                 end

        # Add edition if present
        parts << " #{id.edition}" if id.edition&.number

        parts.join
      end

      # ------------------------------------------------------------------
      # Working document: "100/3705(F)/FDIS" or "PWI TR 100-36 ED1"
      # ------------------------------------------------------------------

      def render_working_document(id)
        # Working Programme format: "PWI TR 100-36 ED1" or "IEC/PWI 60038"
        if id.wp_stage
          parts = []
          if id.publisher
            parts << id.publisher.body
            if id.copublishers&.any?
              parts << "/#{id.copublishers.map(&:body).join('/')}"
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

          parts << " #{id.edition}" if id.edition&.number
          return parts.join
        end

        # Working Document format: "100/3705(F)/FDIS"
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

      # ------------------------------------------------------------------
      # Test Report Form: "IECEE TRF CISPR 14-1:2023"
      # ------------------------------------------------------------------

      def render_test_report_form(id)
        parts = []

        # Publisher and type portion (uses identifier's own publisher_portion)
        parts << id.publisher_portion

        # If CISPR identifier embedded, render it with TRF date
        if id.cispr_identifier
          cispr_parts = []
          cispr_parts << id.cispr_identifier.publisher.body

          num_str = id.cispr_identifier.number.to_s
          num_str += "-#{id.cispr_identifier.part}" if id.cispr_identifier.part && id.cispr_identifier.part.to_s != ""
          cispr_parts << num_str

          cispr_str = cispr_parts.join(" ")
          cispr_str += ":#{id.date.year}" if id.date

          parts << " #{cispr_str}"
        else
          # Normal TRF: number portion (uses identifier's own number_portion)
          parts << id.number_portion
        end

        # TRF info if present
        parts << id.trf_info.to_s if id.trf_info && !id.trf_info.empty?

        parts.compact.join
      end
    end
  end
end
