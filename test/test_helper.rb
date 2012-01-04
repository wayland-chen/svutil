require 'rubygems'
require 'stringio'
require 'test/unit'
require 'mocha'
require File.dirname(__FILE__) + '/../lib/svutil'

class Test::Unit::TestCase
  def assert_exit
    exited = false
    begin
      yield if block_given?
    rescue SystemExit => e
      exited = true
    end
    assert(exited, "Did not exit")
  end
end
