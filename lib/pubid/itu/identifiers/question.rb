# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # ITU Question — the study topics assigned to a study group.
      #
      # Two printed forms, both modelled by this one class:
      #
      #   * numeric (no series):  ITU-R 234-1/7:   ITU-R 237/3:
      #     number(-part)/study-group, always with a trailing ":".
      #   * letter-series:        ITU-R P.3/BL/7   ITU-R SM.1/30
      #     series.number(/BL)?/study-group, optionally bracketed and/or with a
      #     trailing ":" — e.g. ITU-R S.[4/BL/2]:
      #
      # The `/study-group`, the optional "/BL" segment, the surrounding
      # brackets and the trailing ":" have no home on Components::Code, so they
      # are carried here and reconstructed exactly by +render_base+.
      class Question < Identifier
        include StandardSerialization

        attribute :study_group, :string
        attribute :has_bl, :boolean, default: -> { false }
        attribute :bracketed, :boolean, default: -> { false }
        attribute :has_colon, :boolean, default: -> { false }

        # Extra maps merged on top of the StandardSerialization block. The
        # booleans emit only when true (false is stripped as the default), and
        # study_group is a plain scalar.
        key_value do
          map "study_group", to: :study_group
          map "has_bl", to: :has_bl
          map "bracketed", to: :bracketed
          map "has_colon", to: :has_colon
        end

        def render_base(**_opts)
          result = "#{publisher}-#{sector}"
          result += series ? " #{series}." : " "
          result += "[" if bracketed
          result += code.to_s
          result += "/BL" if has_bl
          result += "/#{study_group}"
          result += "]" if bracketed
          result += ":" if has_colon
          result
        end

        def ==(other)
          return false unless other.is_a?(Question)

          sector == other.sector &&
            series == other.series &&
            code == other.code &&
            study_group == other.study_group &&
            has_bl == other.has_bl &&
            bracketed == other.bracketed &&
            has_colon == other.has_colon
        end
      end
    end
  end
end
