# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Addendum identifier (Add.)
      # Pattern: "ITU-T I.363 (1993) Add. 1 (11/1993)"
      class Addendum < Supplement
        def to_s(**opts)
          annotate_plain_render(render_supplement("Add."), **opts)
        end
      end
    end
  end
end
