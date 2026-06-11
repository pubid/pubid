# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Electronic Publication (EP) identifier
      class ElectronicBook < SingleIdentifier
        def self.type
          { key: :ep, title: "Electronic Publication", short: "EP" }
        end

        def to_s(lang: :en, lang_single: false)
          render(format: :human, lang: lang, lang_single: lang_single)
        end
      end
    end
  end
end
