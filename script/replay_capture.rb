# frozen_string_literal: true

# Replay capture: parse every fixture-corpus input with the flavor's own
# parse and record the four render surfaces (to_s, to_hash, to_urn,
# to_mr_string) as JSONL. Run on a baseline commit and on the working
# tree, then diff the two captures — the only diffs are the intended
# render-face moves.
#
#   bundle exec ruby script/replay_capture.rb iec /tmp/baseline-iec.jsonl
#   bundle exec ruby script/replay_capture.rb iso /tmp/baseline-iso.jsonl

flavor = ARGV[0]
out_path = ARGV[1]
abort "usage: replay_capture.rb <flavor> <out.jsonl>" unless flavor && out_path

require "pubid"
require "json"

Pubid.eager_load_flavors!
mod = Pubid::Registry.get(flavor)
abort "unknown flavor #{flavor}" unless mod

fixtures = Dir[File.join(__dir__, "../spec/fixtures/#{flavor}/identifiers/full/*.txt")].sort
abort "no fixtures for #{flavor}" if fixtures.empty?

File.open(out_path, "w") do |out|
  fixtures.each do |path|
    File.readlines(path).each_with_index do |raw, idx|
      input = raw.strip
      next if input.empty? || input.start_with?("#")

      record = { "file" => File.basename(path), "line" => idx + 1,
                 "input" => input }
      begin
        id = mod.parse(input)
        record["class"] = id.class.name
        record["to_s"] = id.to_s
        record["to_hash"] = JSON.generate(id.to_hash)
        begin
          record["to_urn"] = id.to_urn
        rescue StandardError
          record["to_urn"] = nil
        end
        begin
          record["to_mr_string"] = id.to_mr_string
        rescue StandardError => e
          record["to_mr_string"] = "RAISE #{e.class}"
        end
      rescue StandardError => e
        record["class"] = nil
        record["raise"] = e.class.name
      end
      out.puts JSON.generate(record)
    end
  end
end
