require_relative "lib/pubid_new/ieee/identifiers/base"
begin
  result = PubidNew::Ieee::Identifiers::Base.parse("IEEE Std 802-2014")
  puts "✓ PASS: #{result.to_s}"
rescue => e
  puts "✗ FAIL: #{e.class}"
  puts e.message
  puts e.backtrace.first(5)
end
