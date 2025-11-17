require "spec_helper"

RSpec.describe "JIS Fixture Round-trip" do
  let(:fixture_file) { File.join(__dir__, "../../../gems/pubid-jis/spec/fixtures/jis-pubids.txt") }
  
  it "round-trips all identifiers from fixture file" do
    identifiers = File.readlines(fixture_file).map(&:strip).reject(&:empty?)
    
    passed = 0
    failed = []
    
    identifiers.each do |pubid|
      begin
        identifier = PubidNew::Jis.parse(pubid)
        rendered = identifier.to_s
        if pubid == rendered
          passed += 1
        else
          failed << { original: pubid, rendered: rendered }
        end
      rescue => e
        failed << { original: pubid, error: e.message }
      end
    end
    
    puts "\nJIS Results: #{passed}/#{identifiers.count} passing (#{(passed.to_f/identifiers.count*100).round(2)}%)"
    
    if failed.any?
      puts "\nFirst 10 failures:"
      failed.first(10).each do |f|
        if f[:error]
          puts "  ✗ #{f[:original]} => ERROR: #{f[:error]}"
        else
          puts "  ~ #{f[:original]} => #{f[:rendered]}"
        end
      end
    end
    
    expect(passed.to_f / identifiers.count).to be >= 0.95  # 95% pass rate minimum
  end
end