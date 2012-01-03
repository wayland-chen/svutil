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
  end
  
  def test_handle_options
    MyConfig.option_source = [ "-P", "foo", "-x", "12345", "-Q" ]
    MyConfig.init
    assert MyConfig.pid_file = "foo"
    assert MyConfig.x = '1234'
    assert MyConfig.restless
  end

  def test_built_in_options
    MyConfig.option_source = [ "-d", "-P", "foo" ]
    MyConfig.init
    assert MyConfig.daemon
  end
end
