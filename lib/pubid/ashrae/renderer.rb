# frozen_string_literal: true

module Pubid
  module Ashrae
    # Human-readable renderer for ASHRAE identifiers.
    #
    # Produces strings like:
    #   "ASHRAE Standard 15-2024"
    #   "ASHRAE Guideline 0-2019"
    #   "ASHRAE Addendum a to Standard 15-2001"
    #   "ASHRAE Standard 52.2-1999: Addenda Supplement Package"
    #   "ASHRAE Addenda c and d to Standard 15-1994"
    #   "ASHRAE Guideline 0-2005 Errata (September 28, 2011)"
    #   "Interpretations for Standard 15.2-2022"
    #
    # The renderer is registered as the +:human+ format in the ASHRAE format
    # registry and invoked via +render(format: :human)+.
    class Renderer < ::Pubid::Renderers::Base
      def render(context: nil, **_opts)
        id = @id

        case id
        when Identifiers::Addendum
          render_addendum(id)
        when Identifiers::AddendaPackage
          render_addenda_package(id)
        when Identifiers::CombinedAddenda
          render_combined_addenda(id)
        when Identifiers::Errata
          render_errata(id)
        when Identifiers::Interpretation
          render_interpretation(id)
        when SingleIdentifier
          render_single(id)
        else
          render_single(id)
        end
      end

      private

      # SingleIdentifier (Standard, Guideline): "ASHRAE Standard 15-2024"
      def render_single(id)
        parts = []
        parts << id.publisher if id.publisher
        parts << id.type.to_s if id.type
        result = parts.join(" ")
        result += " " if result.length.positive?
        result += id.number.to_s
        result += "-#{id.year}" if id.year
        result += " (#{id.amendment})" if id.amendment
        result += id.suffix if id.suffix
        result += " (RA#{id.reaffirmed})" if id.reaffirmed
        result
      end

      # Addendum: "ASHRAE Addendum a to Standard 15-2001"
      def render_addendum(id)
        return id.base.to_s unless id.base

        base_type = id.base.type || "Standard"

        if id.copublisher
          "#{id.copublisher} Addendum #{id.addendum_code} to #{id.base}"
        else
          result = "ASHRAE Addendum #{id.addendum_code} to #{base_type} #{id.base.number}"
          result += "-#{id.base.year}" if id.base.year
          result
        end.tap { |r| r << " (#{id.addendum_date})" if id.addendum_date }
      end

      # AddendaPackage: "ASHRAE Standard 52.2-1999: Addenda Supplement Package"
      def render_addenda_package(id)
        return id.base.to_s unless id.base

        result = "ASHRAE #{id.base.type || 'Standard'} #{id.base.number}"
        result += "-#{id.base.year}" if id.base.year
        result += ": Addenda #{id.package_description}" if id.package_description
        result
      end

      # CombinedAddenda: "ASHRAE Addenda c and d to Standard 15-1994"
      def render_combined_addenda(id)
        return id.base.to_s unless id.base

        base_type = id.base.type || "Standard"
        if id.addendum_codes
          result = "ASHRAE Addenda #{id.addendum_codes} to #{base_type} #{id.base.number}"
        else
          result = "ASHRAE Addenda to #{base_type} #{id.base.number}"
        end
        result += "-#{id.base.year}" if id.base.year
        result
      end

      # Errata: "ASHRAE Guideline 0-2005 Errata (September 28, 2011)"
      def render_errata(id)
        return id.base.to_s unless id.base

        result = id.base.to_s
        result += " Errata"
        date = long_date(id.date)
        result += " (#{date})" if date
        result
      end

      # The long date form ASHRAE prints on an errata sheet: "October 10,
      # 2008". The component stores padded numbers, so the day loses its
      # leading zero here.
      #
      # The parser always gives a month and a day together, so only the first
      # two shapes come from a reference string. The others can come from a
      # hand-built identifier or from a hash: a date with no day gives "June
      # 2016", a date with only a year gives "2016", and a month number
      # outside 1-12 falls back to the component's own "2016-13-01" form.
      # They must all print something, because the date reaches `to_hash` and
      # the MR slug, and a surface that drops it silently disagrees with them.
      def long_date(date)
        return nil unless date
        return date.year&.to_s unless date.month

        month = Builder::MONTH_NAMES[date.month.to_i - 1]
        return date.to_s unless month

        long_date_with_month(date, month)
      end

      # @param month [String] the month name
      # @return [String] the date, with the day when the date carries one
      def long_date_with_month(date, month)
        return "#{month} #{date.year}".strip unless date.day

        day = "#{month} #{date.day.to_i}"
        date.year ? "#{day}, #{date.year}" : day
      end

      # Interpretation: "Interpretations for Standard 15.2-2022"
      def render_interpretation(id)
        return id.base.to_s unless id.base

        base_type = id.base.type || "Standard"
        result = "Interpretations for #{base_type} #{id.base.number}"
        result += "-#{id.base.year}" if id.base.year
        result
      end
    end
  end
end
