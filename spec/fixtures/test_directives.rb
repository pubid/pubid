#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "pubid/iso"

base_dir = File.expand_path("../..", __dir__)
File.foreach("#{base_dir}/spec/fixtures/iso/identifiers/pass/directives.txt") do |line|
  next if line =~ /^#/ || line.strip.empty?

  id = line.strip
  begin
    parsed = Pubid::Iso.parse(id)
    roundtrip = parsed.to_s
     if roundtrip != id
  rescue StandardError => e
    
  end
end
