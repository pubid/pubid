# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Components
      # Paper identity component for CIE conference proceedings.
      #
      # Groups the paper's code and running number, shared by both surface
      # forms (x-prefixed "CIE x043-OP01" and standalone "CIE OP02 1-5").
      # +code+ is an open set of 1+ uppercase letters (OP, PO, PP, WP, IP,
      # P, ...). No-default strings so the nested hash round-trips cleanly.
      class Paper < Lutaml::Model::Serializable
        attribute :code, :string   # "OP" | "PO" | "PP" | "WP" | "IP" | "P" | ...
        attribute :number, :string # "01"

        def to_s
          "#{code}#{number}"
        end

        def render(context: nil)
          to_s
        end
      end
    end
  end
end
