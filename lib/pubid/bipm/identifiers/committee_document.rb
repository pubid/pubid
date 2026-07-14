# frozen_string_literal: true

module Pubid
  module Bipm
    module Identifiers
      # A committee document: a Recommendation (REC), Resolution (RES),
      # Decision (DECN), Action (ACT) or Declaration (DECL) issued by one of the
      # BIPM committees.
      #
      # Printed forms (all round-trip):
      #   "CCTF REC 2 (2012)"              short, language-neutral
      #   "CCTF REC 2 (2012, E)"           short, with language
      #   "CGPM DECL (1889)"               number-less
      #   "CCL Recommendation 1 (2001)"    full English name  (form: "long")
      #   "Recommandation 1 du CCL (2001)" full French name   (form: "long")
      class CommitteeDocument < Identifier
        def self.type
          { key: :committee_document, web: :committee_document,
            title: "Committee Document", short: "committee-document" }
        end
      end
    end
  end
end
