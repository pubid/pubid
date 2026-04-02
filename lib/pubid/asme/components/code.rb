# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Asme
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :designator, :string    # B, Y, BPVC, etc.
        attribute :number, :string        # 16.5, 14.43, III.1.NB, etc.

        def to_s
          "#{designator}#{number}"
        end
      end
    end
  end
end
