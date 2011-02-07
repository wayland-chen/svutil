require File.dirname(__FILE__) + '/test_helper.rb'

class TestConfig < Test::Unit::TestCase
  include SVUtil

  def setup
  end
  
  def test_set
    assert !Config.my_symbol
    Config.my_symbol = 'abc'
    assert_equal 'abc', Config.my_symbol
    Config.my_var = 10
    assert_equal 10, Config.my_var
  end

  def test_set_with_block
    Config.expects(:validate).times(1)
    Config.set do |c|
      c.another = 'abc'
      c.some_var = 123
      c.foobar = true
    end
    assert_equal 'abc', Config.another
    assert_equal 123, Config.some_var
    assert Config.foobar
  end

  def test_standard_cli_options
    Config.expects(:validate).times(1)
    Config.option_source = [ "-f", "/home/dan/settings", "-d", "-l", "debug", "-T" ]
    Config.init
    assert_equal "/home/dan/settings", Config.config_file
    assert_equal "debug", Config.log_file
    assert Config.daemon
    assert Config.trace
  end

  def test_config_file
    Config.expects(:validate).times(1)
    Config.config_file = "test/settings"
    Config.init
    assert_equal 'bar', Config.foo
  end

  # Command Line wins!
  def test_cli_overide
    Config.expects(:validate).times(1)
    Config.config_file = "test/settings"
    Config.option_source = [ "-l", "logfile_set_on_cli" ]
    Config.init
    assert_equal "logfile_set_on_cli", Config.log_file

  end

  def test_defaults
    Config.defaults do |c|
      c.manager = 'daniel'
    end
    assert_equal 'daniel', Config.manager
    Config.manager = 'james'
    assert_equal 'james', Config.manager
  end

  def test_validations

  end
end
