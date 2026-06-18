# frozen_string_literal: true

module Pubid
  module Astm
    module Identifiers
      class Manual < Base
        attribute :edition, :string          # 9TH, 2ND
        attribute :supplement, :boolean      # -SUP-
        attribute :tp_designation, :string   # TP for technical publications
      end
    end
  end
end
