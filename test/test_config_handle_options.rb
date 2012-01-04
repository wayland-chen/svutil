require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class MyConfig < SVUtil::Config
  handle_options do |opts|
    opts.on("-Q", "--restless", "Feeling restless?") do
      set_cli_option(:restless, true)
    end
    opts.on("-x", "--x-value [value]", "X Value") do |x|
      set_cli_option(:x, x)
    end
  end
end

class TestConfigHandleOptions < Test::Unit::TestCase
  include SVUtil

  def setup
    @my_config = MyConfig.new
  end
  
  def test_handle_options
    @my_config.init([ "-P", "foo", "-x", "12345", "-Q" ])
    assert @my_config.pid_file = "foo"
    assert @my_config.x = '1234'
    assert @my_config.restless
  end

  def test_built_in_options
    @my_config.init([ "-d", "-P", "foo" ])
    assert @my_config.daemon
  end
end
