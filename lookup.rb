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
  dns_records = records.map { |line| line.strip.split(", ") }

  records = {}
  # here i am converting the data into a hash, Type is nothing but the A record and cName records
  dns_records.map do |line|
    if !line.empty?
      records[line[1]] = {
        type: line[0],
        target: line[2],
      }
    end
  end
  return records
end

def resolve(dns_records, lookup_chain, domain)
  # Here i am checking if the domain is present or not
  if dns_records[domain] != nil
    lookup_chain.push(dns_records[domain][:target])
    domain = lookup_chain.last
    resolve(dns_records, lookup_chain, domain)
  else
    # if the lookup_chain length is 1 ,the user have given the wrong domain name
    # if it is greater than 1 and it has a ip address,it will return the DNS result set
    if (lookup_chain.length > 1 and dns_records[lookup_chain[-2]][:type] == "A")
      return lookup_chain
    else
      # lookup_chain[0] is a domain name
      puts "Error: record not found for #{lookup_chain[0]}"
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
