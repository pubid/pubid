#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

# Migration script to move all flavors to identifiers/{full,pass,fail} structure
class FlavorsMigrator
  FLAVOR_CONFIGS = {
    "ansi" => {
      sources: ["gems/pubid-ansi/spec/fixtures/ansi-identifiers.txt"],
      class_name: "international_standard"
    },
    "itu" => {
      sources: ["gems/pubid-itu/spec/fixtures/itu-r.txt"],
      class_name: "recommendation"
    },
    "bsi" => {
      sources: ["gems/pubid-bsi/spec/fixtures/bsi-identifiers.txt"],
      class_name: "international_standard"
    },
    "jis" => {
      sources: ["gems/pubid-jis/spec/fixtures/jis-pubids.txt"],
      class_name: "international_standard"
    },
    "etsi" => {
      sources: ["gems/pubid-etsi/spec/fixtures/pubids.txt"],
      class_name: "technical_specification"
    },
    "ccsds" => {
      sources: [
        "gems/pubid-ccsds/spec/fixtures/active-publications.txt",
        "gems/pubid-ccsds/spec/fixtures/historical-publications.txt"
      ],
      class_name: "international_standard"
    },
    "plateau" => {
      sources: ["gems/pubid-plateau/spec/fixtures/pubids.txt"],
      class_name: "technical_document"
    },
    "cen" => {
      sources: ["gems/pubid-cen/spec/fixtures/cen-identifiers.txt"],
      class_name: "international_standard"
    },
    "idf" => {
      sources: [
        "spec/fixtures/idf/idf-is.txt",
        "spec/fixtures/idf/idf-amdcor.txt",
        "spec/fixtures/idf/idf-rm.txt",
        "spec/fixtures/idf/idf-wd.txt"
      ],
      class_name: "international_standard"
    }
  }.freeze

  def initialize(verbose: true)
    @verbose = verbose
  end

  def migrate_all
    log "Starting migration of all flavors..."
    
    FLAVOR_CONFIGS.each do |flavor, config|
      migrate_flavor(flavor, config)
    end
    
    log "\n✅ All flavors migrated successfully!"
  end

  def migrate_flavor(flavor, config)
    log "\n=== Migrating #{flavor.upcase} ==="
    
    # Create new directory structure
    full_dir = create_directories(flavor)
    
    # Collect all identifiers from source files
    identifiers = collect_identifiers(config[:sources])
    
    if identifiers.empty?
      log "⚠️  No identifiers found for #{flavor}"
      return
    end
    
    # Write to full/ directory
    write_full_file(full_dir, config[:class_name], identifiers)
    
    log "✅ Migrated #{flavor.upcase}: #{identifiers.size} identifiers"
  end

  private

  def create_directories(flavor)
    base_dir = File.join("spec", "fixtures", flavor, "identifiers")
    full_dir = File.join(base_dir, "full")
    pass_dir = File.join(base_dir, "pass")
    fail_dir = File.join(base_dir, "fail")
    
    FileUtils.mkdir_p(full_dir)
    FileUtils.mkdir_p(pass_dir)
    FileUtils.mkdir_p(fail_dir)
    
    log "Created: #{full_dir}"
    full_dir
  end

  def collect_identifiers(source_files)
    identifiers = []
    
    source_files.each do |source|
      next unless File.exist?(source)
      
      File.readlines(source).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")
        identifiers << line
      end
    end
    
    identifiers.uniq.sort
  end

  def write_full_file(full_dir, class_name, identifiers)
    filename = File.join(full_dir, "#{class_name}.txt")
    
    File.open(filename, "w") do |f|
      f.puts "# Auto-generated during migration"
      f.puts "# Source of truth for all identifiers"
      f.puts
      identifiers.each { |id| f.puts id }
    end
    
    log "Wrote #{identifiers.size} identifiers to #{class_name}.txt"
  end

  def log(message)
    puts message if @verbose
  end
end

# Run migration
if __FILE__ == $PROGRAM_NAME
  migrator = FlavorsMigrator.new(verbose: true)
  migrator.migrate_all
end