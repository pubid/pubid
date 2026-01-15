#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/pubid_new"

flavors = Dir["lib/pubid_new/*/"].map { |d| File.basename(d) }.sort

def verify_flavor(flavor)
  puts "Verifying #{flavor.upcase}..."
  errors = []

  # Check for scheme.rb
  unless File.exist?("lib/pubid_new/#{flavor}/scheme.rb")
    errors << "  ❌ Missing scheme.rb"
  else
    puts "  ✓ scheme.rb exists"
  end

  # Check for single_identifier.rb
  unless File.exist?("lib/pubid_new/#{flavor}/single_identifier.rb")
    errors << "  ❌ Missing single_identifier.rb"
  else
    puts "  ✓ single_identifier.rb exists"
  end

  # Check for supplement_identifier.rb
  unless File.exist?("lib/pubid_new/#{flavor}/supplement_identifier.rb")
    errors << "  ❌ Missing supplement_identifier.rb"
  else
    puts "  ✓ supplement_identifier.rb exists"
  end

  # Check for identifiers/base.rb
  unless File.exist?("lib/pubid_new/#{flavor}/identifiers/base.rb")
    errors << "  ❌ Missing identifiers/base.rb"
  else
    puts "  ✓ identifiers/base.rb exists"
  end

  # Check for TYPED_STAGES in identifier classes
  identifier_files = Dir["lib/pubid_new/#{flavor}/identifiers/*.rb"]
  identifier_files.each do |file|
    content = File.read(file)
    if content.include?("class ") && !content.include?("TYPED_STAGES")
      unless file.end_with?("base.rb") || file.end_with?("identifier.rb")
        errors << "  ⚠️  #{File.basename(file)} missing TYPED_STAGES"
      end
    end
  end

  errors
end

all_errors = {}
flavors.each do |flavor|
  next if flavor == "components"
  errors = verify_flavor(flavor)
  all_errors[flavor] = errors if errors.any?
end

puts "\n" + "="*60
puts "ARCHITECTURE VERIFICATION SUMMARY"
puts "="*60

if all_errors.empty?
  puts "✅ All flavors verified!"
else
  puts "⚠️  Issues found:\n\n"
  all_errors.each do |flavor, errors|
    puts "#{flavor.upcase}:"
    errors.each { |e| puts e }
    puts
  end
  exit 1
end
