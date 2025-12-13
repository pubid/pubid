# frozen_string_literal: true

require "lutaml/model"
require_relative "pubid_new/version"
require_relative "pubid_new/scheme"
require_relative "pubid_new/bundled_identifier"
require_relative "pubid_new/iso"
require_relative "pubid_new/idf"
require_relative "pubid_new/iec"
require_relative "pubid_new/cen"
require_relative "pubid_new/ccsds"
require_relative "pubid_new/jis"
require_relative "pubid_new/plateau"
require_relative "pubid_new/etsi"
require_relative "pubid_new/itu"
require_relative "pubid_new/bsi"
require_relative "pubid_new/nist"
require_relative "pubid_new/ieee"
require_relative "pubid_new/ansi"
require_relative "pubid_new/jcgm"
require_relative "pubid_new/oiml"

module PubidNew
  class Error < StandardError; end
  # Your code goes here...
end
