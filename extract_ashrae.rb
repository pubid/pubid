require 'nokogiri'

# Function to extract document identifiers
def extract_identifiers(html_file)
  html_content = File.read(html_file)
  doc = Nokogiri::HTML(html_content)

  identifiers = []

  # Find all <hr> elements
  doc.css('hr').each do |hr|
    # Get the next sibling element
    next_element = hr.next_element
    if next_element && next_element.name == 'p'
      # Find the first <strong> or <b> in the <p>
      bold_element = next_element.at_css('strong') || next_element.at_css('b')
      if bold_element
        # Extract the text, strip whitespace, and add to list if it looks like an identifier
        id_text = bold_element.text.strip
        next if id_text.empty?
        puts "Found identifier: #{id_text}"
        if id_text.match?(/^(SPC|SSPC|GPC|SGPC)/i)
          puts "Skipping non-document identifier: #{id_text}"
          next
        end

        id_text.gsub!(/[-–,\.]\s*$/, '')
        id_text.gsub!(/\s*[-–,\.]\s*Published .*$/, '')
        identifiers << id_text
      end
    end
  end

  identifiers
end

# Usage: Pass the filename as argument or hardcode it
if ARGV.empty?
  puts "Usage: ruby script.rb ashrae-list.html"
  exit
end

file = ARGV[0]
ids = extract_identifiers(file)

puts "Extracted Document Identifiers:"
ids.each { |id| puts id }
