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

    # Auditor compares string-keyed, JSON-shaped data (see Auditor.from_file and
    # auditor_spec.rb), so roundtrip the export through JSON to convert the
    # symbol keys (:identifier_types) into the string keys it expects.
    data = JSON.parse(JSON.generate(Pubid::Export::Exporter.export_all))
    auditor = Pubid::Export::Auditor.new(data)

    # Build a minimal website representation from the generated data itself
    # (in production, this would parse the website's publishers.ts)
    summary = data.transform_values do |fd|
      keys = fd["identifier_types"].map { |t| { "key" => t["key"] } }
      { "doc_types" => keys }
    end

    results = auditor.audit(summary)
    puts auditor.summary(results)
  end
end
