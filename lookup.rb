def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
dns_raw = File.readlines("zone.txt")

def parse_dns(fileContent)
  # select is used to filter the data
  records = fileContent.select { |line| line[0] != "#" }
  dns_records = records.map { |line| line.strip }

  data = {}
  dns_records.select { |line| line[0] == "A" or line[0] == "C" }.map do |line|
    splitted_line = line.split(", ")
    data[splitted_line[1]] = splitted_line[2]
  end
  return data
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records.keys.include? domain
    lookup_chain.push(dns_records[domain])
    domain = lookup_chain.last
    resolve(dns_records, lookup_chain, domain)
  else
    if (lookup_chain.length > 1)
      return lookup_chain
    else
      puts "Error: record not found for #{domain}"
      exit
    end
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")