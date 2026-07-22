# frozen_string_literal: true

module Pubid
  module Iala
    module Identifiers
      # IALA Model Courses (C series).
      # Examples: C0103-1 Ed 3.0, C2001-1 Ed 1.0.
      class ModelCourse < Identifier
        number_width 4

        def self.type
          { key: :"model-course", title: "Model Course", short: "C" }
        end
      end
    end
  end
end
