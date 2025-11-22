require_relative 'gems/pubid-bsi/lib/pubid-bsi'

test_cases = [
  'BS EN 15154-5:2019',
  'BS ISO/IEC 30134-1:2016',
  'BS ISO/DIS 22000:2017',
  'BS ISO/FDIS 22301:2012',
  'DD CEN/TS 1992-4-2:2009',
  'PD CEN/TS 16415:2013',
  'PD IEC TR 80002-3:2014',
  'BS EN ISO 13485:2012',
  'BS EN ISO 13485:2016+A11:2021',
  'BS EN IEC 62368-1:2020+A11:2020',
]

puts 'BSI PubID - Adopted Documents Test (Phase 2)'
puts '='*60

passed = 0
failed = 0

test_cases.each do |test|
  begin
    identifier = Pubid::Bsi::Identifier.parse(test)
    rendered = identifier.to_s
    if test == rendered
      passed += 1
      puts "✓ #{test}"
    else
      failed += 1
      puts "~ #{test} => #{rendered}"
    end
  rescue => e
    failed += 1
    puts "✗ #{test} => #{e.message.split("\n").first}"
  end
end

puts
puts '='*60
puts "RESULTS: #{passed}/#{test_cases.count} passing (#{(passed.to_f/test_cases.count*100).round(1)}%)"
puts '='*60