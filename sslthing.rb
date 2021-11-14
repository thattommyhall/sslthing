# frozen_string_literal: true

require 'powerdns_pipe'

pipe = PowerDNS::Pipe.new(banner: 'sslthing')

IP_REGEX = /^(\d{1,3})-(\d{1,3})-(\d{1,3})-(\d{1,3})\./

def extract_ip(name)
  match = IP_REGEX.match(name)
  if match
    octets = match.captures
    octets.each do |octet|
      i = octet.to_i
      if !(i < 255 and i >= 0)
        return nil
      end
    end
    octets.join('.')
  end
end

if __FILE__ == $PROGRAM_NAME
  pipe.run! do
    name = question.name
    if question.qtype == 'A' or question.qtype == 'ANY'
      extracted = extract_ip(name)
      if extracted
        answer(name: name, content: extracted, type: 'A')
      end
    end
  end
end
