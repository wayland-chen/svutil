module SVUtil
  class ProcessManager
    def initialize(klass)
      Signal.trap("INT") { shutdown('Interupted') }
      Signal.trap("TERM") { shutdown('Terminated') }
      if running?
        STDERR.puts "There is already a '#{$0}' process running"
        exit 1
      end
      daemonize if SVUtil::config.daemon
      write_pid_file
      @klass = klass
      @server_instance = @klass.new
    end

    def start
      begin
        @server_instance.run
      rescue
        STDERR.puts $!
        STDERR.puts $!.backtrace if SVUtil::config.trace
      ensure
        shutdown("Process Completed")
        exit 1
      end
    end

    private
      def shutdown(reason = nil)
        Log.info "Shutting Down (#{reason})"
        @server_instance.shutdown if @server_instance.respond_to?(:shutdown)
        remove_pid_file
        exit 0
      end

      def running?
        pid_file = SVUtil::config.pid_file
        return false unless pid_file
        File.exist?(pid_file)
      end

      def write_pid_file
        pid_file = SVUtil::config.pid_file
        return unless pid_file
        File.open(pid_file, "w") { |f| f.write(Process.pid) }
        File.chmod(0644, pid_file)
      end

      def remove_pid_file
        pid_file = SVUtil::config.pid_file
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
