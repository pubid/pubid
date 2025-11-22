#!/usr/bin/env ruby

# Simple script to capture failing identifiers
def capture_failures(flavor)
  puts "Capturing #{flavor} failures..."
  
  # Run tests and capture output
  output = `bundle exec rspec spec/integration/#{flavor}_spec.rb --format documentation 2>&1`
  
  failures = []
  current_identifier = nil
  
  output.lines.each do |line|
    # Look for failing test lines
    if line =~ /parses ['"]([^'"]+)['"]/ && line =~ /FAILED|failed|FAIL/
      current_identifier = $1
      failures << current_identifier
    elsif line =~ /parses ['"]([^'"]+)['"]/ && line =~ /ERROR|error/
      current_identifier = $1
      failures << current_identifier
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
  
  failures.each do |identifier|
    if identifier =~ /Draft/
      categories["Draft Patterns"] << identifier
    elsif identifier =~ /and/
      categories["Dual Published (and)"] << identifier
    elsif identifier =~ /\([^)]+\)/
      categories["Adopted Standard (parenthetical)"] << identifier
    elsif identifier =~ /IEEE\/IEC|IEC\/IEEE/
      categories["IEC/IEEE Copublished"] << identifier
    elsif identifier =~ /Std\s+\d+/
      categories["Standard Numbers"] << identifier
    elsif identifier =~ /\d+\.\d+/
      categories["Version.Iteration"] << identifier
    elsif identifier =~ /Redline/
      categories["Redlined Standard"] << identifier
    elsif identifier =~ /P\d+|Project\s+\d+/
      categories["Project Numbers"] << identifier
    elsif identifier =~ /CORR|Corrigendum/
      categories["Corrigendum"] << identifier
    elsif identifier =~ /Amd|Amendment/
      categories["Amendment"] << identifier
    else
      categories["Other Patterns"] << identifier
    end
  end
  
  # Write to MD file
  File.open("/tmp/#{flavor}_failures_categorized.md", "w") do |f|
    f.puts "# #{flavor.upcase} Failing Identifiers Analysis"
    f.puts
    f.puts "Total failures: #{failures.length}"
    f.puts
    
    categories.each do |category, identifiers|
      next if identifiers.empty?
      
      f.puts "## #{category}"
      f.puts
      f.puts "Count: #{identifiers.length}"
      f.puts
      
      identifiers.each do |identifier|
        f.puts "### `#{identifier}`"
        f.puts
        
        # Add pattern analysis
        f.puts "**Pattern Analysis:**"
        if identifier =~ /Draft\s+(\w+)\s+(\d+(?:\.\d+)?)/
          f.puts "- Draft type: #{$1}"
          f.puts "- Version: #{$2}"
        elsif identifier =~ /and/
          f.puts "- Dual published identifier"
        elsif identifier =~ /\(([^)]+)\)/
          f.puts "- Adopted from: #{$1}"
        elsif identifier =~ /IEEE\/IEC|IEC\/IEEE/
          f.puts "- Copublished by IEEE and IEC"
        elsif identifier =~ /P(\d+)/
          f.puts "- Project number: #{$1}"
        elsif identifier =~ /(\d+)\.(\d+)/
          f.puts "- Version: #{$1}, Iteration: #{$2}"
        end
        f.puts
      end
    end
  end
  
  puts "Analysis written to /tmp/#{flavor}_failures_categorized.md"
end

# Analyze both flavors
capture_failures('ieee')
capture_failures('nist')