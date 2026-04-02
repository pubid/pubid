#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "pubid_new/iso"

base_dir = File.expand_path("../../..", __FILE__)
File.foreach("#{base_dir}/spec/fixtures/iso/identifiers/pass/directives.txt") do |line|
  next if line =~ /^#/ || line.strip.empty?
  id = line.strip
  begin
    parsed = PubidNew::Iso.parse(id)
    roundtrip = parsed.to_s
    puts "FAIL: #{id} -> #{roundtrip}" if roundtrip != id
  rescue => e
    puts "ERROR: #{id} - #{e.message}"
  end
end
