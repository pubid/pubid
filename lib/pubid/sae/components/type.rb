# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Sae
    module Components
      # The SAE document family: the letters before the number.
      #
      # +abbr+ holds the printed form (+AMS-QQ-A+). SAE's DOI suffixes drop
      # the hyphens (+10.4271/amsqqa250_4b+), so the parser reads both
      # spellings and the builder stores the printed one (see
      # +.canonical+).
      class Type < Lutaml::Model::Serializable
        include ::Pubid::SubsetMatch

        # Printed form => the separator SAE prints between it and the number.
        # A family transferred from a military or industry series keeps that
        # series' hyphen (+AMS-QQ-A-250+, +GEIA-STD-0001+, +EIA-649+); the
        # SAE-native families print the number glued (+AMS4121J+, +J3016+).
        # The grammar's +doc_type+ alternatives list exactly these keys plus
        # their hyphen-free spellings; +spec/pubid/sae/type_table_spec.rb+
        # keeps the two in step.
        TYPES = {
          "AMS" => "", "AS" => "", "J" => "", "ARP" => "", "AIR" => "",
          "MA" => "", "MAM" => "", "MAP" => "", "JA" => "", "MS" => "",
          "ARD" => "", "TSB" => "", "CMB" => "", "SSB" => "",
          "CRP" => "-", "USCAR" => "-",
          "EIA" => "-", "EIA-IS" => "-", "EIA-STD" => "-",
          "GEIA" => "-", "GEIA-STD" => "-", "GEIA-HB" => "-", "GEIA-OP" => "-",
          "GEIA-TB" => "-",
          "AMS-STD" => "-", "AMS-DTL" => "-", "AMS-WW-T" => "-",
          "AMS-QQ-A" => "-", "AMS-QQ-C" => "-", "AMS-QQ-N" => "-",
          "AMS-QQ-P" => "-", "AMS-QQ-S" => "-", "AMS-QQ-W" => "-",
          "AMS-PRF" => "-",
          "AMS-A" => "-", "AMS-B" => "-", "AMS-C" => "-", "AMS-D" => "-",
          "AMS-F" => "-",
          "AMS-G" => "-", "AMS-H" => "-", "AMS-I" => "-", "AMS-L" => "-",
          "AMS-M" => "-", "AMS-P" => "-", "AMS-R" => "-", "AMS-S" => "-",
          "AMS-T" => "-", "AMS-W" => "-"
        }.freeze

        # Hyphen-free spelling => printed form.
        CANONICAL = TYPES.keys.to_h { |abbr| [abbr.delete("-"), abbr] }.freeze

        # The families whose revision is a dash number (+USCAR2-6+ is
        # USCAR-2 Revision 6), not a letter.
        DASH_REVISION = %w[USCAR].freeze

        # The families whose trailing +M+ marks the metric edition of a
        # document (+J174M+), not a revision.
        METRIC_SUFFIX = %w[J JA].freeze

        attribute :abbr, :string

        # @param spelling [String] +AMSQQA+, +AMS-QQ-A+ or +ams-qq-a+
        # @return [String, nil] the printed form, nil for an unknown family
        def self.canonical(spelling)
          CANONICAL[spelling.to_s.upcase.delete("-")]
        end

        # The separator printed between this family and its number.
        def separator
          TYPES.fetch(abbr.to_s, "")
        end

        def to_s
          render
        end

        def render(context: nil)
          abbr.to_s
        end
      end
    end
  end
end
