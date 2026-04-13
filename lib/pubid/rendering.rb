# frozen_string_literal: true

module Pubid
  module Rendering
    autoload :Base, "pubid/rendering/base"
    autoload :Common, "pubid/rendering/common"
    autoload :Date, "pubid/rendering/date"
    autoload :Format, "pubid/rendering/format"
    autoload :Language, "pubid/rendering/language"
    autoload :Numbering, "pubid/rendering/numbering"
    autoload :Publisher, "pubid/rendering/publisher"
    autoload :Stage, "pubid/rendering/stage"
    autoload :Supplement, "pubid/rendering/supplement"
    autoload :RenderingContext, "pubid/rendering/context"
    autoload :Annotator, "pubid/rendering/annotator"
  end
end
