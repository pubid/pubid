# frozen_string_literal: true

module Pubid
  module Bipm
    # Human-readable renderer for the four BIPM identifier families. Registered
    # as the `:human` format and invoked via `render(format: :human)`.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        case @id
        when Identifiers::CommitteeDocument then render_committee(@id)
        when Identifiers::Meeting then render_meeting(@id)
        when Identifiers::MetrologiaArticle then render_metrologia(@id)
        when Identifiers::SiBrochure then render_si_brochure(@id)
        when Identifiers::Mep then render_mep(@id)
        when Identifiers::Guide then render_guide(@id)
        else
          raise "Cannot render BIPM identifier: #{@id.class}"
        end
      end

      private

      # Optional " <number>" segment (with a leading space), or "" when absent.
      def number_segment(id)
        id.number ? " #{id.number}" : ""
      end

      # Optional " (<year>[, <lang>])" segment (with a leading space), or ""
      # when the year is absent (a partial reference). `lang` is the trailing
      # ", E"/", F" suffix carried only by the short committee form.
      def year_segment(id, lang: "")
        id.year ? " (#{id.year}#{lang})" : ""
      end

      def render_committee(id)
        return render_committee_long(id) if id.long?

        # short abbreviated key form. The type word is optional — the bare MRA
        # form (e.g. "CIPM 2005-06") has no type_code, so omit it (and its
        # leading space) rather than emit a double space.
        lang = id.language ? ", #{id.language}" : ""
        type = id.type_code ? " #{id.type_code}" : ""
        "#{id.group}#{type}#{number_segment(id)}#{appendix_segment(id)}" \
          "#{year_segment(id, lang: lang)}"
      end

      # The complement tail "{identifier} A{appendix}[.{annex}]" of the guide's
      # resource-specific-id numbering (parts/subparts are dash forms inside
      # `number` itself; appendices/annexes are this separate tail).
      def appendix_segment(id)
        return "" unless id.appendix

        annex = id.annex ? ".#{id.annex}" : ""
        " A#{id.appendix}#{annex}"
      end

      def render_committee_long(id)
        if id.language == "F"
          name = Identifier::TYPE_NAME_FR[id.type_code]
          # The guide's body-prefixed French pattern ("Décision CIPM/111-10
          # (2022)") is the canonical long face: the group qualifies the
          # resource-specific id with a slash. A number-less document has no
          # id to qualify, so it keeps the connective spelling the guide's
          # general French pattern uses ("Statement de la CGPM (1889)").
          if id.number
            return "#{name} #{id.group}/#{id.number}#{year_segment(id)}"
          end

          conn = Identifier.french_connective(id.group)
          "#{name}#{number_segment(id)} #{conn} #{id.group}#{year_segment(id)}"
        else
          name = Identifier::TYPE_NAME_EN[id.type_code]
          "#{id.group} #{name}#{number_segment(id)}#{year_segment(id)}"
        end
      end

      def render_meeting(id)
        if id.language == "F"
          "#{id.group} #{id.number}<sup>e</sup> réunion#{year_segment(id)}"
        else
          "#{id.group} #{id.ordinal_en} Meeting#{year_segment(id)}"
        end
      end

      def render_metrologia(id)
        result = +"Metrologia"
        result << " #{id.volume}" if id.volume
        result << " #{id.issue}" if id.issue
        result << " #{id.article}" if id.article
        result
      end

      def render_si_brochure(id)
        # Appendix / derived-product form indexed by relaton, keyed on the full
        # "BIPM SI Brochure …" primary docidentifier content.
        return "BIPM SI Brochure #{id.variant}" if id.variant
        # Bare or sectioned reference: no edition means no version and no year
        # to print either — just the brochure, optionally down to one part.
        return "BIPM SI Brochure#{part_segment(id)}" unless id.edition

        # The version is optional (the guide's "SI Brochure 9e (2019, E)" form)
        # and the language code too (the language-independent form), so both
        # segments are conditional. The parens carry the year, the language or
        # both, and stay off entirely when the reference names neither ("SI
        # Brochure 9e", the bare-number alias without a year).
        phrase = id.language == "F" ? "sur le SI " : ""
        lang = id.language ? ", #{id.language}" : ""
        tail = id.years ? "#{id.years}#{lang}" : id.language.to_s
        result = +"BIPM SI Brochure #{phrase}#{id.edition}"
        result << " #{id.version}" if id.version
        result << " (#{tail})" if id.years || id.language
        result
      end

      # Optional " Part <n>" segment of an SI Brochure section reference.
      def part_segment(id)
        id.part ? " Part #{id.part}" : ""
      end

      # MEP: short docnumber ("SI MEP <code>" / "Rapport BIPM-YYYY/NN"), or the
      # full "BIPM … Appendix N [Annex N] Part N.M" content the crawler keys on.
      def render_mep(id)
        body = id.report_code ? "Rapport #{id.report_code}" : "SI MEP #{id.mep_code}"
        render_full_content(id, body)
      end

      # CC guide: short "<committee>-GD-<kind>-<number>", or its full
      # "BIPM … Appendix N Part N.M" content form.
      def render_guide(id)
        body = "#{id.group}-GD-#{id.guide_kind}-#{id.number}"
        render_full_content(id, body)
      end

      # Wrap a short body in the "BIPM … Appendix N [Annex N] Part N.M" content
      # form when the identifier carries the appendix/part tail; otherwise emit
      # the bare short body. `part` presence is what distinguishes the two.
      def render_full_content(id, body)
        return body unless id.part

        annex = id.annex ? " Annex #{id.annex}" : ""
        "BIPM #{body} Appendix #{id.appendix}#{annex} Part #{id.part}"
      end
    end
  end
end
