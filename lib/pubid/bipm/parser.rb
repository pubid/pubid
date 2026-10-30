# frozen_string_literal: true

module Pubid
  module Bipm
    # Grammar for the four BIPM identifier families. The root branches
    # by leading token / shape; each alternative is wrapped in a distinct key
    # (:committee_short, :meeting_en, …) so the Builder can dispatch on the
    # matched branch without re-inspecting the string.
    #
    # Group and type-word alternations are built from the shared vocabularies on
    # {Identifier} (sorted longest-first so e.g. "CCTF" is tried before "CCT").
    class Parser
    end
  end
end
