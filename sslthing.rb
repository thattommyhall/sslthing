# frozen_string_literal: true

require 'logger'
require 'powerdns_pipe'
require 'uri'
require 'net/http'

pipe = PowerDNS::Pipe.new(banner: 'sslthing')
DOMAINS = ['sslify.me', 'sslocal.io']

NS_IP = '151.139.184.11'
IP_REGEX = /^(\d{1,3})-(\d{1,3})-(\d{1,3})-(\d{1,3})\./

def extract_ip(name)
  match = IP_REGEX.match(name)
  return unless match

  octets = match.captures[0..3]
  octets.each do |octet|
    i = octet.to_i
    return nil unless i < 255 and i >= 0
  end
  octets.join('.')
end

def soa(domain)
  "ns.#{domain}. hostmaster.#{domain}. 1 600 300 1209600 60"
end

def response_for(username)
  uri = URI("http://challenges.sslify.me.s3-website-eu-west-1.amazonaws.com/twitter/#{username}")
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

if __FILE__ == $PROGRAM_NAME
  log = Logger.new('/var/log/powerdns-pipe.log', 'daily')
  log.level = Logger::DEBUG
  pipe.run! do
    name = question.name.downcase
    qtype = question.qtype
    log.debug("#{qtype}: #{name}")

    if name.start_with?('_acme-challenge') and %w[TXT ANY].include?(qtype)
      match = /_acme-challenge.(?<username>[\w+]{1,15}).(?<domain>sslify.me|sslocal.io)/.match(name)
      username = match[:username]
      response = response_for(username)
      answer(name: name, content: response, type: 'TXT', ttl: 120)
    end

    if DOMAINS.include?(name)
      case qtype
      when 'NS'
        answer(name: name, content: "ns.#{name}", type: 'NS')
      when 'SOA'
        answer(name: name, content: soa(name), type: 'SOA')
      when 'ANY'
        answer(name: name, content: "ns.#{name}", type: 'NS')
        answer(name: name, content: soa(name), type: 'SOA')
      end
    end

    name_servers = DOMAINS.map { |domain| "ns.#{domain}" }

    if name_servers.include?(name) and %w[A ANY].include?(qtype)
      answer(name: name, content: NS_IP, type: 'A')
    end

    extracted = extract_ip(name)
    if extracted and %w[A ANY].include?(qtype)
      answer(name: name, content: extracted, type: 'A')
    end
  end
end
