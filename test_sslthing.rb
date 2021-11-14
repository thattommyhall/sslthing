# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'sslthing'

class SSLThingTest < MiniTest::Test
  def test_detect_query
    assert_equal extract_ip('192-168-0-1.tth.things.something'), '192.168.0.1'
    assert_nil extract_ip('192-168-0-allaa.tth.things.something')
    assert_nil extract_ip('192-168-0-255.tth.things.something')
  end
end
