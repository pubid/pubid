require_relative "base"

module Pubid
  module Cen
    module Renderer
      class CombinedBundle
        attr_reader :object

        def initialize(object)
          @object = object
        end

        def render
          result = object.base_document.to_s

          # Add amendments with + prefix
          object.amendments.each do |amendment|
            result += "+#{amendment}"
          end

          # Add corrigendums with + prefix
          object.corrigendums.each do |corrigendum|
            result += "+#{corrigendum}"
          end

          result
        end
      end
    end
  end
end
