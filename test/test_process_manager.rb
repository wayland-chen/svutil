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
    ServerConfig.clear_all
  end
  
  def test_initialize
    ProcessManager.new(@klass, ServerConfig)
  end

  def test_initialize_and_start_with_server_instance
    pm = ProcessManager.new(@instance, ServerConfig)
    @instance.expects(:run)
    assert_exit { pm.start }
  end

  # TODO: Could probably test this better by actually forking
  def test_start_as_daemon
    ServerConfig.daemon = true
    pm = ProcessManager.new(@klass, ServerConfig)
    pm.expects(:daemonize)
    pm.expects(:write_pid_file)
    pm.expects(:shutdown)
    @instance.expects(:run)
    pm.start
  end

  def test_start_with_trace
    ServerConfig.trace = true
    pm = ProcessManager.new(@klass, ServerConfig)
    pm.expects(:write_pid_file)
    @instance.expects(:run).raises(Exception)
    Log.expects(:error).times(2)
    assert_exit { pm.start }
  end

  def test_shutdown
    pm = ProcessManager.new(@klass, ServerConfig)
    pm.expects(:write_pid_file)
    @instance.expects(:run)
    assert_exit { pm.start }

    # Shutdown
    @instance.expects(:shutdown)
    pm.expects(:remove_pid_file)
    assert_exit { pm.send(:shutdown) }
  end

  def test_shutdown_with_trace
    ServerConfig.trace = true
    pm = ProcessManager.new(@klass, ServerConfig)
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
