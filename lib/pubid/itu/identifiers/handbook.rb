# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # ITU Handbook
      # Format: ITU-{SECTOR} {NUMBER}.HDB
      # Example: ITU-R 23.HDB
      #
      # Handbooks are companion publications keyed to a study-group number; the
      # printed form is the number followed by the literal ".HDB" marker. There
      # is no series and (in practice) no date.
      class Handbook < Identifier
        include StandardSerialization

        def render_base(**_opts)
          result = "#{publisher}-#{sector} #{code&.number}.HDB"

          if date
            result += if date.month
                        " (#{date.month}/#{date.year})"
                      else
                        " (#{date.year})"
                      end
          end

          result
        end

        def ==(other)
          return false unless other.is_a?(Handbook)

          sector == other.sector && code == other.code && date == other.date
        end
      end
    end
  end
end
