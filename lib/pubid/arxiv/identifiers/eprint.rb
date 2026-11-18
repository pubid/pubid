# frozen_string_literal: true

module Pubid
  module Arxiv
    module Identifiers
      # An arXiv e-print, new form or old form.
      #
      # Examples:
      #   arXiv:2301.00001v1
      #   arXiv:0704.0001
      #   arXiv:hep-th/9901001v2
      #   arXiv:math.GT/0309136
      class Eprint < Identifier
        def self.type
          { key: :eprint, title: "arXiv e-print", short: "arXiv" }
        end
      end
    end
  end
end
