#!/usr/bin/env ruby

require 'json'

def analyze_fixture_failures(flavor)
  puts "Analyzing #{flavor} fixture failures..."
  
  # Get the fixture file path
  fixture_files = case flavor
  when 'ieee'
    Dir.glob("gems/pubid-ieee/spec/fixtures/*.txt")
  when 'nist'
    Dir.glob("gems/pubid-nist/spec/fixtures/*.txt")
  else
    []
  end
  
  puts "Found fixture files: #{fixture_files}"
  
  all_identifiers = []
  fixture_files.each do |file|
    if File.exist?(file)
      identifiers = File.readlines(file).map(&:strip).reject(&:empty?)
      all_identifiers.concat(identifiers)
      puts "Loaded #{identifiers.length} identifiers from #{file}"
    end
  end
  
  puts "Total identifiers to test: #{all_identifiers.length}"
  
  # Test each identifier
  failures = []
  all_identifiers.each_with_index do |identifier, index|
    begin
      # Try to parse the identifier
      result = `ruby -e "
        require './lib/pubid_new'
        begin
          parsed = PubidNew::#{flavor.capitalize}.parse('#{identifier.gsub("'", "\\\\'")}')
          puts 'SUCCESS'
        rescue => e
          puts 'FAIL: ' + e.message
        end
      "`
      
      if result.include?('FAIL')
        failures << {
          identifier: identifier,
          error: result.strip
        }
      end
      
      if (index + 1) % 100 == 0
        puts "Tested #{index + 1}/#{all_identifiers.length} identifiers, found #{failures.length} failures"
      end
    rescue => e
      puts "Error testing #{identifier}: #{e.message}"
    end
  end
  
  puts "Found #{failures.length} failing identifiers for #{flavor}"
  
  # Categorize failures
  categories = {
    "Draft Patterns" => [],
    "Dual Published (and)" => [],
    "Adopted Standard (parenthetical)" => [],
    "IEC/IEEE Copublished" => [],
    "Standard Numbers" => [],
    "Version.Iteration" => [],
    "Redlined Standard" => [],
    "Project Numbers" => [],
    "Corrigendum" => [],
    "Amendment" => [],
    "Other Patterns" => []
  }
  
  failures.each do |failure|
    identifier = failure[:identifier]
    
    if identifier =~ /Draft/i
      categories["Draft Patterns"] << failure
    elsif identifier =~ /\band\b/i
      categories["Dual Published (and)"] << failure
    elsif identifier =~ /\([^)]+\)/
      categories["Adopted Standard (parenthetical)"] << failure
    elsif identifier =~ /IEEE\/IEC|IEC\/IEEE/i
      categories["IEC/IEEE Copublished"] << failure
    elsif identifier =~ /Std\s+\d+/i
      categories["Standard Numbers"] << failure
    elsif identifier =~ /\d+\.\d+/
      categories["Version.Iteration"] << failure
    elsif identifier =~ /Redline/i
      categories["Redlined Standard"] << failure
    elsif identifier =~ /P\d+|Project\s+\d+/i
      categories["Project Numbers"] << failure
    elsif identifier =~ /CORR|Corrigendum/i
      categories["Corrigendum"] << failure
    elsif identifier =~ /Amd|Amendment/i
      categories["Amendment"] << failure
    else
      categories["Other Patterns"] << failure
    end
  end
  
  # Write to MD file
  File.open("/tmp/#{flavor}_failures_categorized.md", "w") do |f|
    f.puts "# #{flavor.upcase} Failing Identifiers Analysis"
    f.puts
    f.puts "Total failures: #{failures.length}"
    f.puts
    
    categories.each do |category, failures_in_category|
      next if failures_in_category.empty?
      
      f.puts "## #{category}"
      f.puts
      f.puts "Count: #{failures_in_category.length}"
      f.puts
      
      failures_in_category.each do |failure|
        f.puts "### `#{failure[:identifier]}`"
        f.puts
        f.puts "**Error:** #{failure[:error]}"
        f.puts
        
        # Add pattern analysis
        f.puts "**Pattern Analysis:**"
        identifier = failure[:identifier]
        if identifier =~ /Draft\s+(\w+)\s+(\d+(?:\.\d+)?)/i
          f.puts "- Draft type: #{$1}"
          f.puts "- Version: #{$2}"
        elsif identifier =~ /\band\b/i
          f.puts "- Dual published identifier"
        elsif identifier =~ /\(([^)]+)\)/
          f.puts "- Adopted from: #{$1}"
        elsif identifier =~ /IEEE\/IEC|IEC\/IEEE/i
          f.puts "- Copublished by IEEE and IEC"
        elsif identifier =~ /P(\d+)/i
          f.puts "- Project number: #{$1}"
        elsif identifier =~ /(\d+)\.(\d+)/
          f.puts "- Version: #{$1}, Iteration: #{$2}"
        elsif identifier =~ /(\d{4})/
          f.puts "- Year: #{$1}"
        end
        f.puts
      end
    end
  end
  
  puts "Analysis written to /tmp/#{flavor}_failures_categorized.md"
end

# Analyze both flavors
analyze_fixture_failures('ieee')
analyze_fixture_failures('nist')