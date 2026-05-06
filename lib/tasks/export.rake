# frozen_string_literal: true

require "json"

namespace :export do
  desc "Export library metadata as JSON for the PubID website"
  task :website_data do
    require "pubid/export"
    data = Pubid::Export::Exporter.export_all
    output_path = File.expand_path("website-data.json", __dir__)
    File.write(output_path, JSON.pretty_generate(data))
    puts "Exported #{data.keys.size} flavors to #{output_path}"
    data.each do |flavor, fd|
      count = fd[:identifier_types]&.size || 0
      puts "  #{flavor}: #{count} identifier types"
    end
  end

  desc "Audit library data against website publishers"
  task :audit do
    require "pubid/export"
    data = Pubid::Export::Exporter.export_all

    # Parse website publishers to extract doc type keys
    # For now, read the generated JSON and provide a summary
    auditor = Pubid::Export::Auditor.new(data)

    # Build a minimal website representation from the generated data itself
    # (in production, this would parse the website's publishers.ts)
    {}
    summary = data.transform_values do |fd|
      { "doc_types" => fd[:identifier_types].map { |t| { "key" => t[:key] } } }
    end

    results = auditor.audit(summary)
    puts auditor.summary(results)
  end
end
