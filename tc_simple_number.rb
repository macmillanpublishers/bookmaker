# File:  tc_simple_number.rb

require_relative "./simple_number.rb"
require "test/unit"
require_relative "./core/htmlmaker/htmlmaker.rb"
# require_relative './core/header.rb'
# require_relative './core/metadata.rb'

class TestSimpleNumber < Test::Unit::TestCase
puts 'runnig test 1'
  def test_simple
    assert_equal(4, SimpleNumber.new(2).add(2) )
    assert_equal(6, SimpleNumber.new(2).multiply(3) )
  end

end

class HtmlmakerTests < Test::Unit::TestCase
puts 'runnig test 2'
  def demo_method_test
		assert_equal(5, increment(4))
	end

end
puts '4'
