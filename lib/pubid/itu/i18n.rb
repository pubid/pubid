# frozen_string_literal: true

require "yaml"

module Pubid
  module Itu
    I18N = YAML.load_file(File.expand_path("i18n.yaml", __dir__)).freeze
  end
end
