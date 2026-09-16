# frozen_string: true

module Pubid
  module Itu
    module Identifiers
      # ITU Contribution (Temporary Document) — the working documents a study
      # group circulates, numbered per study group.
      #
      # Format: ITU-{SECTOR} {SERIES}-C{NUMBER}    e.g. ITU-R SG17-C1000
      #
      # Mirrors pubid-itu 1.15's Pubid::Itu::Identifier::Contribution
      # ("%{series}-C%{number}"), which metanorma-itu builds from
      # `:doctype: contribution` documents (pubid#340).
      class Contribution < Identifier
        include StandardSerialization

        def render_base(**_opts)
          "#{publisher}-#{sector} #{series}-C#{code&.number}"
        end

        def ==(other)
          return false unless other.is_a?(Contribution)

          sector == other.sector &&
            series == other.series &&
            code == other.code
        end
      end
    end
  end
end
