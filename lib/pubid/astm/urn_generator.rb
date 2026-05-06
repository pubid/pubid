# frozen_string_literal: true

module Pubid
  module Astm
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "astm"]

        if identifier.type
          type = identifier.type&.abbr || identifier.type.to_s
          parts << type.to_s.downcase
        else
          parts << "std"
        end

        if identifier.code
          parts << identifier.code.to_s
        end

        number = maybe(:number)
        if number
          num = number.to_s
          parts << num
        end

        part = maybe(:part)
        if part
          p = part.to_s
          parts[-1] = "#{parts[-1]}-#{p}"
        end

        subpart = maybe(:subpart)
        if subpart
          sp = subpart.to_s
          parts[-1] = "#{parts[-1]}-#{sp}"
        end

        year = extract_year
        parts << year if year

        sub_year = maybe(:sub_year)
        parts << sub_year.to_s if sub_year

        reapproval = maybe(:reapproval)
        parts << "reapp.#{reapproval}" if reapproval

        edition = maybe(:edition)
        parts << "e#{edition}" if edition

        wip = maybe(:work_in_progress)
        parts << "wip" if wip

        wk = maybe(:wk)
        parts << "wk.#{wk}" if wk

        pub = identifier.publisher
        if pub
          p = pub.to_s
          parts[1] = p.to_s.downcase
        end

        copubs = maybe(:copublishers)
        if copubs&.any?
          cp = copubs.map(&:to_s)
          parts[1] = "#{parts[1]}-#{cp.join('-').downcase}"
        end

        if identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      private

      def extract_year
        year = maybe(:year)
        if year
          y = year.to_s
          y = y[-2..] if y.length == 4
          return y
        end

        date = identifier.date
        if date
          y = date.year&.to_s
          if y
            y = y[-2..] if y.length == 4
            return y
          end
        end

        nil
      end
    end
  end
end
