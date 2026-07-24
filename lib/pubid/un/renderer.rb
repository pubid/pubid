# frozen_string_literal: true

module Pubid
  module Un
    class Renderer < ::Pubid::Renderers::Base
      def render(**_opts)
        (@id.path + [@id.number]).join("/")
      end
    end
  end
end
