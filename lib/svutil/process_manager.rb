module SVUtil
  class ProcessManager
    def initialize(klass_or_instance, config)
      @server_instance = if klass_or_instance.instance_of?(Class)
        klass_or_instance.new
      else
        klass_or_instance
      end
      @config = config

      # TODO: Add ability for users to specify these signals
      Signal.trap("INT") { shutdown('Interupted', 1) }
      Signal.trap("TERM") { shutdown('Terminated', 2) }
      unless RUBY_PLATFORM =~ /(win|w)32$/
        Signal.trap("PIPE") { shutdown('Broken Pipe', 4) }
      end
      if running?
        STDERR.puts "There is already a '#{$0}' process running"
        exit 1
      end
    end

    def start
      begin
        daemonize if @config.daemon
        write_pid_file
        @server_instance.run
      rescue SystemExit => e
        shutdown("System Exited")
      rescue Exception => e
        Log.error(e.message)
        Log.error(e.backtrace.join("\n")) if @config.trace
        shutdown("Process Completed with Error", 1)
      end
      shutdown("Process Completed")
    end

    private
      def shutdown(reason = nil, exit_code = 0)
        Log.info "Shutting Down (#{reason})"
        begin
          @server_instance.shutdown if @server_instance.respond_to?(:shutdown)
        rescue Exception => e
          Log.error("Shutdown Callback threw error: #{e.message}")
          Log.error("Shutdown Callback threw error: #{e.backtrace}") if @config.trace
          Log.info("Shuting down anyway")
        end
        remove_pid_file
        exit exit_code
      end

      def running?
        pid_file = @config.pid_file
        return false unless pid_file
        File.exist?(pid_file)
      end

      def write_pid_file
        pid_file = @config.pid_file
        return unless pid_file
        File.open(pid_file, "w") { |f| f.write(Process.pid) }
        File.chmod(0644, pid_file)
      end

      def remove_pid_file
        pid_file = @config.pid_file
        return unless pid_file
        File.unlink(pid_file) if File.exists?(pid_file)
      end

      def daemonize
        fork and exit
      	redirect_io
      end

      def redirect_io
        begin; STDIN.reopen('/dev/null'); rescue Exception; end
        if SVUtil::config.log_file
          begin
            STDOUT.reopen(SVUtil::config.log_file, "a")
            STDOUT.sync = true
          rescue Exception
            begin; STDOUT.reopen('/dev/null'); rescue Exception; end
          end
        else
          begin; STDOUT.reopen('/dev/null'); rescue Exception; end
        end
        begin; STDERR.reopen(STDOUT); rescue Exception; end
        STDERR.sync = true
      end
  end
end
