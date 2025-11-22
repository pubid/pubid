require_relative 'lib/pubid_new'

# All adopted document test cases from spec lines 104-199
test_cases = [
  # Single-level adoptions - ISO/IEC
  'BS ISO/IEC 30134-1:2016',
  'BS ISO/PAS 5643',
  'BS ISO/DIS 22000:2017',
  'BS ISO/DIS 9004.1:2017',
  'BS ISO/FDIS 22301:2012',
  
  # Single-level adoptions - IEC
  'PD IEC TR 80002-3:2014',
  
  # Single-level adoptions - CEN
  'DD CEN/TS 1992-4-2:2009',
  'BS EN 15154-5:2019',
  'PD CEN/TS 16415:2013',
  
  # Multi-level adoptions (BS EN ISO, BS EN IEC)
  'BS EN ISO 13485:2012',
  'BS EN ISO 13485:2016+A11:2021',
  'BS EN IEC 62368-1:2020+A11:2020',
  'BS EN ISO/IEC 80079-34:2020 ED2',
  'PD CISPR TR 16-4-5:2006+A2:2021',
  
  # Expert Commentary with adopted docs
  'BS EN ISO 13485:2016+A11:2021 ExComm',
  'BS EN 61000-3-3:2013+A2:2021 ExComm',
  'BS EN IEC 62115:2020+A11:2020 ExComm',
  'BS EN ISO/IEC 80079-34:2020 ExComm',
]

puts 'BSI PubID v2 - Comprehensive Adopted Documents Test'
puts '='*60

passed = 0
failed = 0
details = []

test_cases.each do |test|
  begin
    identifier = PubidNew::Bsi.parse(test)
    rendered = identifier.to_s
    if test == rendered
      passed += 1
      puts "✓ #{test}"
    else
      failed += 1
      puts "~ #{test}"
      puts "   => #{rendered}"
      details << { test: test, got: rendered, status: :mismatch }
    end
  rescue => e
    failed += 1
    puts "✗ #{test}"
    puts "   => #{e.message.split("\n").first}"
    details << { test: test, error: e.message, status: :error }
  end
end

puts
puts '='*60
puts "RESULTS: #{passed}/#{test_cases.count} passing (#{(passed.to_f/test_cases.count*100).round(1)}%)"
puts '='*60

if details.any?
  puts
  puts "FAILED TESTS:"
  details.each do |d|
    puts "  #{d[:test]}"
    if d[:status] == :mismatch
      puts "    Got: #{d[:got]}"
    else
      puts "    Error: #{d[:error]}"
    end
  end
end