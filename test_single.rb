require "bundler/setup"
require_relative "lib/pubid_new/nist/parser"

pattern = "NIST SP 500-268v1.1"
puts "Testing: #{pattern}"
puts "=" * 60

# Show what preprocessing does
cleaned = pattern.to_s.strip
cleaned = cleaned.sub(/^nbs\b/i, 'NBS')
cleaned = cleaned.sub(/^nist\b/i, 'NIST')
cleaned = cleaned.gsub(/([-\d]+[IVX]+[-\d]+)\s+(\d+)/, '\1.\2')
cleaned = cleaned.gsub(/(\d)rev(\d{4})/, '\1 rev\2')
cleaned = cleaned.gsub(/(\d)Pt(\d+)(r\d+)/, '\1 pt\2 \3')
cleaned = cleaned.gsub(/(\d)ver(\d)/, '\1 ver\2')
cleaned = cleaned.gsub(/ver(\d+)e(\d{4})/, 'ver\1 e\2')
cleaned = cleaned.gsub(/ver(\d+)v(\d+)/, 'ver\1 v\2')
cleaned = cleaned.gsub(/(\d)(v\d+\.\d+)/, '\1 \2')
cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)/, '\1.\2')
cleaned = cleaned.gsub(/(\d+)-upd/, '\1 -upd')
cleaned = cleaned.gsub(/(\d+)\/upd/, '\1 /upd') 
cleaned = cleaned.gsub(/([a-z]\d+)\/upd/, '\1 /upd')
cleaned = cleaned.gsub(/\s+(\d+)pd$/, ' \1 pd')
cleaned = cleaned.gsub(/(\d+)\s+Suppl\b/, '\1Suppl')
cleaned = cleaned.gsub(/(\d{3,})\s+(\d{1,2})$/, '\1_\2')

puts "After preprocessing: '#{cleaned}'"
puts "=" * 60

begin
  result = PubidNew::Nist::Parser.new.parse(cleaned)
  puts "SUCCESS!"
  puts result.inspect
rescue => e
  puts "FAILED: #{e.message[0..200]}"
end
