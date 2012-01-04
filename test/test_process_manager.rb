require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class ServerConfig < SVUtil::Config
end

class TestProcesManager < Test::Unit::TestCase
  include SVUtil

  def setup
    Signal.stubs(:trap)
    Log.stubs(:info)
    @instance = mock()
    @klass = mock
    @klass.stubs(:new).returns(@instance)
    @klass.stubs(:instance_of?).with(Class).returns(true)
  end
  
  def test_initialize
    config = ServerConfig.new
    ProcessManager.new(@klass, config)
  end

  def test_initialize_and_start_with_server_instance
    config = ServerConfig.new
    pm = ProcessManager.new(@instance, config)
    @instance.expects(:run)
    assert_exit { pm.start }
  end

  # TODO: Could probably test this better by actually forking
  def test_start_as_daemon
    config = ServerConfig.new
    config.daemon = true
    pm = ProcessManager.new(@klass, config)
    pm.expects(:daemonize)
    pm.expects(:write_pid_file)
    pm.expects(:shutdown)
    @instance.expects(:run)
    pm.start
  end

  def test_start_with_trace
    config = ServerConfig.new
    config.trace = true
    pm = ProcessManager.new(@klass, config)
    pm.expects(:write_pid_file)
    @instance.expects(:run).raises(Exception)
    Log.expects(:error).times(2)
    assert_exit { pm.start }
  end

  def test_shutdown
    config = ServerConfig.new
    pm = ProcessManager.new(@klass, config)
    pm.expects(:write_pid_file)
    @instance.expects(:run)
    assert_exit { pm.start }

    # Shutdown
    @instance.expects(:shutdown)
    pm.expects(:remove_pid_file)
    assert_exit { pm.send(:shutdown) }
  end

  def test_shutdown_with_trace
    config = ServerConfig.new
    config.trace = true
    pm = ProcessManager.new(@klass, config)
    pm.expects(:write_pid_file)
    @instance.expects(:run)
    assert_exit { pm.start }

    # Shutdown
    @instance.expects(:shutdown).raises(Exception)
    Log.expects(:error).times(2)
    pm.expects(:remove_pid_file)
    assert_exit { pm.send(:shutdown) }
  end


  # TODO: Test all of the exceptions
end
