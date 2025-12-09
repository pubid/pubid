#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

# Fixtures Extraction Script for spec/fixtures/{flavor}/{pass,fail}/{class}.txt
# Note: This script expects PubID libraries to be already loaded
class FixturesExtractor
  FLAVORS = %w[iso iec ieee nist idf cen bsi jis etsi ccsds itu plateau ansi].freeze
  
  attr_reader :flavor, :verbose, :output_dir
  
  def initialize(flavor, verbose: false)
    @flavor = flavor.downcase
    @verbose = verbose
    @output_dir = File.join(__dir__, flavor)
    @stats = {
      total: 0,
      passing: 0,
      failing: 0,
      by_class: Hash.new { |h, k| h[k] = { pass: 0, fail: 0 } }
    }
    validate_flavor!
  end
  
  def extract
    log "Extracting fixtures for #{flavor.upcase}..."
    
    # Find source fixture files
    fixture_files = find_fixture_files
    if fixture_files.empty?
      puts "⚠️  No fixture files found for #{flavor.upcase}"
      return false
    end
    
    log "Found #{fixture_files.size} fixture files"
    
    # Create output directories
    FileUtils.mkdir_p(File.join(output_dir, "pass"))
    FileUtils.mkdir_p(File.join(output_dir, "fail"))
    
    # Process each fixture file
    fixture_files.each do |fixture_file|
      process_fixture_file(fixture_file)
    end
    
    # Generate summary
    generate_summary
    
    log "✅ Extraction complete for #{flavor.upcase}"
    log "   Output directory: #{output_dir}"
    true
  end
  
  private
  
  def validate_flavor!
    unless FLAVORS.include?(flavor)
      raise ArgumentError, "Unknown flavor: #{flavor}. Valid: #{FLAVORS.join(', ')}"
    end
  end
  
  def find_fixture_files
    pattern = "archived-gems/pubid-#{flavor}/spec/fixtures/*.txt"
    # Adjust path when run from spec/fixtures directory
    pattern = "../../#{pattern}" if Dir.pwd.end_with?("spec/fixtures")
    Dir.glob(pattern).select { |f| File.file?(f) }
  end
  
  def process_fixture_file(fixture_file)
    log "Processing: #{File.basename(fixture_file)}"
    
    identifiers = File.readlines(fixture_file)
                      .map(&:strip)
                      .reject { |line| line.empty? || line.start_with?("#") }
    
    identifiers.each do |id_str|
      @stats[:total] += 1
      
      begin
        parsed = parse_identifier(id_str)
        
        if parsed.to_s == id_str
          # Success - passing fixture
          @stats[:passing] += 1
          class_name = detect_class_name(parsed, id_str)
          @stats[:by_class][class_name][:pass] += 1
          append_to_file("pass", class_name, id_str)
        else
          # Format mismatch - failing fixture
          @stats[:failing] += 1
          class_name = detect_class_name(parsed, id_str)
          @stats[:by_class][class_name][:fail] += 1
          append_to_file("fail", class_name, id_str, 
                        comment: "Renders as: #{parsed.to_s}")
        end
      rescue StandardError => e
        # Parse error - failing fixture
        @stats[:failing] += 1
        class_name = detect_class_from_string(id_str)
        @stats[:by_class][class_name][:fail] += 1
        append_to_file("fail", class_name, id_str,
                      comment: "Parse error: #{e.class.name}")
      end
    end
  end
  
  def parse_identifier(id_str)
    case flavor
    when "iso" then PubidNew::Iso.parse(id_str)
    when "iec" then PubidNew::Iec.parse(id_str)
    when "ieee" then PubidNew::Ieee.parse(id_str)
    when "nist" then PubidNew::Nist.parse(id_str)
    when "jis" then PubidNew::Jis.parse(id_str)
    when "etsi" then PubidNew::Etsi.parse(id_str)
    when "ccsds" then PubidNew::Ccsds.parse(id_str)
    when "itu" then PubidNew::Itu.parse(id_str)
    when "plateau" then PubidNew::Plateau.parse(id_str)
    when "ansi" then PubidNew::Ansi.parse(id_str)
    when "cen" then PubidNew::Cen.parse(id_str)
    when "bsi" then PubidNew::Bsi.parse(id_str)
    when "idf" then PubidNew::Idf.parse(id_str)
    else
      raise "Unknown flavor: #{flavor}"
    end
  end
  
  def detect_class_name(parsed, original_str)
    # Get class name from parsed object
    class_name = parsed.class.name.split("::").last
    
    # Convert to underscore format
    underscore(class_name)
  rescue StandardError
    # Fallback to string-based detection
    detect_class_from_string(original_str)
  end
  
  def detect_class_from_string(id_str)
    case flavor
    when "iso" then detect_iso_class(id_str)
    when "iec" then detect_iec_class(id_str)
    when "ieee" then detect_ieee_class(id_str)
    when "nist" then detect_nist_class(id_str)
    else "unknown"
    end
  end
  
  def detect_iso_class(id_str)
    return "nsb_format" if id_str =~ /FprISO|PrISO/
    return "cyrillic" if id_str =~ /[А-Яа-яЁё]/
    return "guide" if id_str =~ /Guide/i
    return "directives" if id_str =~ /DIR/
    return "amendment" if id_str =~ /\/Amd|\/AMD|\/FDAM|\/PDAM|\/DAM/
    return "corrigendum" if id_str =~ /\/Cor|\/COR|\/FDCOR|\/DCOR/
    return "technical_report" if id_str =~ /\bTR\b/
    return "technical_specification" if id_str =~ /\bTS\b/
    return "pas" if id_str =~ /\bPAS\b/
    return "iwa" if id_str =~ /\bIWA\b/
    return "addendum" if id_str =~ /\/Add/
    "international_standard"
  end
  
  def detect_iec_class(id_str)
    return "technical_report" if id_str =~ /\bTR\b/
    return "technical_specification" if id_str =~ /\bTS\b/
    return "guide" if id_str =~ /GUIDE/i
    return "pas" if id_str =~ /\bPAS\b/
    return "srd" if id_str =~ /\bSRD\b/
    return "amendment" if id_str =~ /\/AMD/
    return "corrigendum" if id_str =~ /\/COR/
    return "interpretation_sheet" if id_str =~ /\/ISH/
    return "vap" if id_str =~ /\bVAP\b/
    return "consolidated" if id_str =~ /\+AMD|\+COR/
    "international_standard"
  end
  
  def detect_ieee_class(id_str)
    return "unapproved" if id_str =~ /Unapproved/
    return "draft" if id_str =~ /\/D\d/
    return "adopted" if id_str =~ /\(Adoption\)/
    return "no_std_prefix" if id_str !~ /\bStd\b/ && id_str =~ /^IEEE/
    return "historical" if id_str =~ /^AIEE|^IRE/
    "standard"
  end
  
  def detect_nist_class(id_str)
    return "fips" if id_str =~ /\bFIPS\b/
    return "sp" if id_str =~ /\bSP\b/
    return "ir" if id_str =~ /\bIR\b/
    return "tn" if id_str =~ /\bTN\b/
    return "hb" if id_str =~ /\bHB\b/
    return "gcr" if id_str =~ /\bGCR\b/
    return "bms" if id_str =~ /\bBMS\b/
    "unknown"
  end
  
  def append_to_file(status, class_name, identifier, comment: nil)
    filename = File.join(output_dir, status, "#{class_name}.txt")
    
    # Initialize file with header if it doesn't exist
    unless File.exist?(filename)
      File.open(filename, "w") do |f|
        f.puts "# #{flavor.upcase} #{class_name.tr('_', ' ').capitalize} - #{status.capitalize}"
        f.puts "# Auto-generated by extract_fixtures.rb"
        f.puts
      end
    end
    
    # Append identifier (with optional comment)
    File.open(filename, "a") do |f|
      f.puts "# #{comment}" if comment
      f.puts identifier
    end
  end
  
  def generate_summary
    filename = File.join(output_dir, "SUMMARY.txt")
    
    File.open(filename, "w") do |f|
      f.puts "Flavor: #{flavor.upcase}"
      f.puts "Extracted: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts "Source: archived-gems/pubid-#{flavor}/spec/fixtures/*.txt"
      f.puts "=" * 70
      f.puts
      
      f.puts "OVERALL STATISTICS"
      f.puts "-" * 70
      f.puts "Total Identifiers: #{@stats[:total]}"
      f.puts "Passing: #{@stats[:passing]} (#{percentage(@stats[:passing], @stats[:total])}%)"
      f.puts "Failing: #{@stats[:failing]} (#{percentage(@stats[:failing], @stats[:total])}%)"
      f.puts
      
      f.puts "BY IDENTIFIER CLASS"
      f.puts "-" * 70
      f.puts "#{"Class".ljust(30)} | #{"Pass".rjust(6)} | #{"Fail".rjust(6)} | #{"Total".rjust(6)} | Pass%"
      f.puts "-" * 70
      
      @stats[:by_class].sort_by { |k, _| k }.each do |class_name, counts|
        total = counts[:pass] + counts[:fail]
        pass_pct = percentage(counts[:pass], total)
        
        f.puts "#{class_name.ljust(30)} | #{counts[:pass].to_s.rjust(6)} | #{counts[:fail].to_s.rjust(6)} | #{total.to_s.rjust(6)} | #{pass_pct.to_s.rjust(5)}%"
      end
      
      f.puts
      f.puts "FILES GENERATED"
      f.puts "-" * 70
      
      pass_files = Dir.glob(File.join(output_dir, "pass", "*.txt")).map { |f| File.basename(f) }.sort
      fail_files = Dir.glob(File.join(output_dir, "fail", "*.txt")).map { |f| File.basename(f) }.sort
      
      f.puts "Pass directory: #{pass_files.size} files"
      pass_files.each { |file| f.puts "  - #{file}" }
      
      f.puts
      f.puts "Fail directory: #{fail_files.size} files"
      fail_files.each { |file| f.puts "  - #{file}" }
      
      f.puts
      f.puts "ASSESSMENT"
      f.puts "-" * 70
      pass_rate = percentage(@stats[:passing], @stats[:total])
      
      if pass_rate >= 99
        f.puts "Status: PERFECT ✅"
        f.puts "Assessment: Production-ready with excellent coverage."
      elsif pass_rate >= 95
        f.puts "Status: EXCELLENT ✅"
        f.puts "Assessment: Production-ready with minor limitations."
      elsif pass_rate >= 80
        f.puts "Status: PRODUCTION-READY ✅"
        f.puts "Assessment: Suitable for production use. Enhancement opportunities identified."
      elsif pass_rate >= 50
        f.puts "Status: PARTIAL ⚠️"
        f.puts "Assessment: Core functionality working. Significant enhancement needed."
      else
        f.puts "Status: NEEDS WORK ❌"
        f.puts "Assessment: Major parser enhancements required."
      end
    end
    
    log "Generated: SUMMARY.txt"
    
    # Print summary to console
    puts
    puts "=" * 70
    puts "EXTRACTION COMPLETE: #{flavor.upcase}"
    puts "=" * 70
    puts "Total: #{@stats[:total]} identifiers"
    puts "Pass:  #{@stats[:passing]} (#{percentage(@stats[:passing], @stats[:total])}%)"
    puts "Fail:  #{@stats[:failing]} (#{percentage(@stats[:failing], @stats[:total])}%)"
    puts
    puts "Classes: #{@stats[:by_class].size}"
    puts "Output:  #{output_dir}"
    puts "=" * 70
  end
  
  def percentage(part, whole)
    return 0 if whole.zero?
    ((part.to_f / whole) * 100).round(2)
  end
  
  def underscore(camel_cased_word)
    camel_cased_word.to_s.gsub("::", "/")
                    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                    .tr("-", "_")
                    .downcase
  end
  
  def log(message)
    puts message if verbose
  end
end