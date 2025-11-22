require_relative 'lib/pubid_new'

# Comprehensive BSI test covering all phases
test_cases = [
  # Phase 1: Basic BSI documents
  'BS 0',
  'BS 7121-3:2017',
  'PAS 1192-2:2014',
  'PD 19650-0:2019',
  'DD 240-1:1997',
  'BSI Flex 8670:2021-04',
  'BSI Flex 1889 v1.0:2022-07',
  'BS 4592-0:2006+A1:2012',
  'PD 5500:2021+A2:2022',
  'PAS 3002:2018+C1:2018',
  'BS 5250:2021 ExComm',
  'BS 7273-4:2015+A1:2021 ExComm',
  'PAS 96:2017 - TC',
  'PAS 2035/2030:2019+A1:2022',
  
  # Phase 2: Adopted documents - Single level
  'BS ISO/IEC 30134-1:2016',
  'BS ISO/PAS 5643',
  'BS ISO/DIS 22000:2017',
  'BS ISO/FDIS 22301:2012',
  'PD IEC TR 80002-3:2014',
  'DD CEN/TS 1992-4-2:2009',
  'BS EN 15154-5:2019',
  'PD CEN/TS 16415:2013',
  
  # Phase 2: Adopted documents - Multi-level
  'BS EN ISO 13485:2012',
  'BS EN ISO 13485:2016+A11:2021',
  'BS EN IEC 62368-1:2020+A11:2020',
  'BS EN ISO/IEC 80079-34:2020 ED2',
  'PD CISPR TR 16-4-5:2006+A2:2021',
  
  # Phase 2: Adopted + ExComm
  'BS EN ISO 13485:2016+A11:2021 ExComm',
  'BS EN 61000-3-3:2013+A2:2021 ExComm',
  'BS EN IEC 62115:2020+A11:2020 ExComm',
  'BS EN ISO/IEC 80079-34:2020 ExComm',
  
  # National Annexes
  'NA to BS EN 1999-1-2:2007',
  'NA+A1:2012 to BS EN 1993-5:2007',
  'NA+A1:2015 to BS EN 1993-1-4:2006+A1:2015',
  'NA+A2:2018 to BS EN 1991-1-3:2003+A1:2015',
  
  # Translations
  'BS 25999-1:2006 (German)',
  'PAS 99:2006 (Italian)',
  'BS ISO/IEC 17799:2005 (French)',
  
  # PDF marker
  'PD 5500:2018+A3:2020 PDF',
]

puts 'BSI PubID v2 - Complete Feature Test (Phase 1 + 2)'
puts '='*60

passed = 0
failed = 0
categories = {
  basic: 0,
  adopted_single: 0,
  adopted_multi: 0,
  expert_comm: 0,
  national_annex: 0,
  translation: 0,
  pdf: 0
}

test_cases.each_with_index do |test, idx|
  begin
    identifier = PubidNew::Bsi.parse(test)
    rendered = identifier.to_s
    
   if test == rendered
      passed += 1
      puts "✓ #{test}"
      
      # Categorize
      if idx < 14
        categories[:basic] += 1
      elsif idx < 22
        categories[:adopted_single] += 1
      elsif idx < 27
        categories[:adopted_multi] += 1
      elsif idx < 31
        categories[:expert_comm] += 1
      elsif idx < 35
        categories[:national_annex] += 1
      elsif idx < 38
        categories[:translation] += 1
      else
        categories[:pdf] += 1
      end
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
puts "TOTAL: #{passed}/#{test_cases.count} passing (#{(passed.to_f/test_cases.count*100).round(1)}%)"
puts '='*60
puts
puts "By Category:"
puts "  Basic BSI: #{categories[:basic]}/14"
puts "  Single-level Adopted: #{categories[:adopted_single]}/8"
puts "  Multi-level Adopted: #{categories[:adopted_multi]}/5"
puts "  Expert Commentary: #{categories[:expert_comm]}/4"
puts "  National Annexes: #{categories[:national_annex]}/4"
puts "  Translations: #{categories[:translation]}/3"
puts "  PDF: #{categories[:pdf]}/1"
puts '='*60