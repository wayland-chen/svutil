require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class CustomConfig < SVUtil::Config
  defaults do |c|
    c.foo = 'bar'
    c.manager = 'daniel'
  end
end

class TestConfig < Test::Unit::TestCase
  include SVUtil

  def setup
    @custom_config = CustomConfig.new
  end
  
  def test_set
    assert !@custom_config.my_symbol
    @custom_config.my_symbol = 'abc'
    assert_equal 'abc', @custom_config.my_symbol
    @custom_config.my_var = 10
    assert_equal 10, @custom_config.my_var
  end

  def test_set_with_block
    @custom_config.expects(:validate).times(1)
    @custom_config.set do |c|
      c.another = 'abc'
      c.some_var = 123
      c.foobar = true
    end
    assert_equal 'abc', @custom_config.another
    assert_equal 123, @custom_config.some_var
    assert @custom_config.foobar
  end

  def test_standard_cli_options
    @custom_config = CustomConfig.new
    @custom_config.expects(:validate).times(1)
    #@custom_config.option_source = [ "-f", "test/settings", "-d", "-l", "debug", "-T" ]
    @custom_config.init([ "-f", "test/settings", "-d", "-l", "debug", "-T" ])
    assert_equal "test/settings", @custom_config.config_file
    assert_equal "debug", @custom_config.log_file
    assert @custom_config.daemon
    assert @custom_config.trace
  end

  def test_config_file
    @custom_config.expects(:validate).times(1)
    @custom_config.config_file = "test/settings"
    @custom_config.init
    assert_equal 'bar', @custom_config.foo
  end

  def test_load_config_file
    @custom_config.expects(:load_config_file).times(1)
    @custom_config.config_file = "test/settings"
    @custom_config.init
    assert_equal 'bar', @custom_config.foo
  end

  def test_validations_on_cli_with_no_config_file
    @custom_config.expects(:validate).times(1)
    @custom_config.config_file = nil
    @custom_config.init
  end

  # Command Line wins!
  def test_file_overide
    @custom_config.expects(:validate).times(1)
    @custom_config.config_file = "test/settings"
    @custom_config.init([ "-l", "logfile_set_on_cli" ])
    assert_equal "logfile_set_on_cli", @custom_config.log_file
  end

  def test_defaults
    assert_equal 'daniel', @custom_config.manager
    @custom_config.manager = 'james'
    assert_equal 'james', @custom_config.manager
  end

  def test_custom_defaults
    assert_equal 'bar', @custom_config.foo
  end
end
