# frozen_string_literal: true

require 'minitest/autorun'
require 'resolv'

require_relative 'sslthing'

class SSLThingTest < MiniTest::Test
  def test_detect_query
    assert_equal extract_ip('192-168-0-1.tth.things.something'), '192.168.0.1'
    assert_nil extract_ip('192-168-0-allaa.tth.things.something')
    assert_nil extract_ip('192-168-0-255.tth.things.something')
  end

  def test_fetch_challenge
    assert_equal "SOME-STRING", response_for("testuser")
  end
end

def get_A(name)
  dns = Resolv::DNS.new(nameserver_port: [['127.0.0.1', 2000]])
  result = dns.getresources(name, Resolv::DNS::Resource::IN::A)
  if result.length > 0
    result.first.address.to_s
  end
end

def get_TXT(name)
  dns = Resolv::DNS.new(nameserver_port: [['127.0.0.1', 2000]])
  result = dns.getresources(name, Resolv::DNS::Resource::IN::TXT)
  if result.length > 0
    result.first.strings.first
  end
end

def get_NS(name)
  dns = Resolv::DNS.new(nameserver_port: [['127.0.0.1', 2000]])
  result = dns.getresources(name, Resolv::DNS::Resource::IN::NS)
  if result.length > 0
    result.first.name.to_s
  end
end

class SSLThingTest < MiniTest::Test
  def test_ns_query
    assert_equal 'ns.sslify.me', get_NS('sslify.me')
    assert_equal 'ns.sslocal.io', get_NS('sslocal.io')
  end

  def test_a_lookups
    assert_equal '1.2.3.4', get_A('1-2-3-4.thattommyhall.sslify.me')
    assert_equal '1.2.3.4', get_A('1-2-3-4.thattommyhall.sslocal.io')
    assert_nil get_A('1-2-3-4.thattommyhall.rando.domain')
  end

  def test_challenge
    assert_equal 'SOME-STRING', get_TXT('_acme-challenge.testuser.sslify.me')
  end
end
