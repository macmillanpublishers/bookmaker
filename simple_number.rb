# File:  simple_number.rb
# require 'rubygems'
# require 'bundler/setup'
# require 'fileutils'
# Bundler.require(:default)

require 'json'

class SimpleNumber

  def initialize(num)
    raise unless num.is_a?(Numeric)
    @x = num
  end

  def add(y)
    @x + y
  end

  def multiply(y)
    @x * y
  end

end

json = JSON.generate [1, 2, {"a"=>3.141}, false, true, nil, 4..10]
