# frozen_string_literal: true

module Pubid
  module Renderers
    autoload :Base, "pubid/renderers/base"
    autoload :DirectivesRenderer, "pubid/renderers/directives_renderer"
    autoload :GuideRenderer, "pubid/renderers/guide_renderer"
    autoload :HumanReadable, "pubid/renderers/human_readable"
    autoload :IwaRenderer, "pubid/renderers/iwa_renderer"
    autoload :MrString, "pubid/renderers/mr_string"
    autoload :SupplementRenderer, "pubid/renderers/supplement_renderer"
    autoload :Urn, "pubid/renderers/urn"
  end
end
