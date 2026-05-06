# frozen_string_literal: true

module Pubid
  class FormatRegistry
    attr_reader :formats

    def initialize(parent: nil)
      @formats = {}
      @parent = parent
    end

    def register(format, renderer: nil, parser: nil)
      @formats[format.to_sym] = { renderer:, parser: }
    end

    def renderer_for(format)
      entry = @formats[format.to_sym]
      return entry[:renderer] if entry && entry[:renderer]
      return @parent.renderer_for(format) if @parent

      nil
    end

    def parser_for(format)
      entry = @formats[format.to_sym]
      return entry[:parser] if entry && entry[:parser]
      return @parent.parser_for(format) if @parent

      nil
    end

    def registered_formats
      formats = @formats.keys
      formats |= @parent.registered_formats if @parent
      formats
    end

    def has?(format)
      @formats.key?(format.to_sym) || (@parent&.has?(format) || false)
    end
  end
end
