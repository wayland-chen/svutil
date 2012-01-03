require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class CustomConfig < SVUtil::Config
  defaults do |c|
    c.foo = 'bar'
  end
end

class TestConfig < Test::Unit::TestCase
  include SVUtil

  def setup
  end
  
  def test_set
    assert !CustomConfig.my_symbol
    CustomConfig.my_symbol = 'abc'
    assert_equal 'abc', CustomConfig.my_symbol
    CustomConfig.my_var = 10
    assert_equal 10, CustomConfig.my_var
  end

  def test_set_with_block
    CustomConfig.expects(:validate).times(1)
    CustomConfig.set do |c|
      c.another = 'abc'
      c.some_var = 123
      c.foobar = true
    end
    assert_equal 'abc', CustomConfig.another
    assert_equal 123, CustomConfig.some_var
    assert CustomConfig.foobar
  end

  def test_standard_cli_options
    CustomConfig.expects(:validate).times(1)
    CustomConfig.option_source = [ "-f", "test/settings", "-d", "-l", "debug", "-T" ]
    CustomConfig.init
    assert_equal "test/settings", CustomConfig.config_file
    assert_equal "debug", CustomConfig.log_file
    assert CustomConfig.daemon
    assert CustomConfig.trace
  end

  def test_config_file
    CustomConfig.expects(:validate).times(1)
    CustomConfig.config_file = "test/settings"
    CustomConfig.init
    assert_equal 'bar', CustomConfig.foo
  end

  def test_load_config_file
    CustomConfig.expects(:load_config_file).times(1)
    CustomConfig.config_file = "test/settings"
    CustomConfig.init
    assert_equal 'bar', CustomConfig.foo
  end

  def test_validations_on_cli_with_no_config_file
    CustomConfig.expects(:validate).times(1)
    CustomConfig.config_file = nil
    CustomConfig.init
  end

  # Command Line wins!
  def test_file_overide
    CustomConfig.expects(:validate).times(1)
    CustomConfig.config_file = "test/settings"
    CustomConfig.option_source = [ "-l", "logfile_set_on_cli" ]
    CustomConfig.init
    assert_equal "logfile_set_on_cli", CustomConfig.log_file
  end

  def test_defaults
    CustomConfig.defaults do |c|
      c.manager = 'daniel'
    end
    assert_equal 'daniel', CustomConfig.manager
    CustomConfig.manager = 'james'
    assert_equal 'james', CustomConfig.manager
  end

  def test_custom_defaults
    assert_equal 'bar', CustomConfig.foo
  end
end
