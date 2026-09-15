# frozen_string_literal: true

require "yaml"
require "fileutils"

namespace :conformance do
  desc "Generate the neutral corpus from ground-truth fixtures"
  task :generate, [:flavor] do |_t, args|
    require "pubid"
    require "pubid/conformance"
    flavor = args[:flavor] || "iso"
    tests_repo = ENV.fetch("PUBID_TESTSUITE_PATH",
                           File.expand_path("../../../pubid-testsuite", 
                                            __dir__))
    output_dir = File.join(tests_repo, "tests", flavor)
    FileUtils.mkdir_p(output_dir)
    results = Pubid::Conformance::Generator.new(flavor)
      .generate(output_dir: output_dir)
    stats = results
    puts "#{flavor}: #{stats[:files]} files, #{stats[:cases]} cases, " \
         "#{stats[:aliases]} aliases, #{stats[:duplicates]} duplicates, " \
         "#{stats[:reclassify]} reclassify, #{stats[:negative]} negative, " \
         "#{stats[:debt]} debt, #{stats[:roundtrip_failures]} rt-failures"
  end

  desc "Run the neutral corpus against this implementation"
  task :run do
    require "pubid"
    require "pubid/conformance"
    failures = Pubid::Conformance::Runner.new.run.flatten
    puts "TOTAL failures: #{failures.size}"
    exit(failures.empty? ? 0 : 1)
  end
end
