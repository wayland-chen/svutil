module SVUtil
  class ProcessManager
    def initialize(klass)
      Signal.trap("INT") { shutdown }
      Signal.trap("TERM") { shutdown }
      if running?
        STDERR.puts "There is already a '#{$0}' process running"
        exit 1
      end
      daemonize if SVUtil::config.daemon
      write_pid_file
      @klass = klass
    end

    def start
			begin
        @klass.new.run
			rescue
				puts $!
			ensure
				remove_pid_file
				exit 1
			end
    end

    private
      def shutdown
        Log.info "Shutting Down"
        @klass.shutdown if @klass.respond_to?(:shutdown)
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