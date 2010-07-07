require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

module SVUtil
  def self.config
    Config.config_class
  end
 
  class Config
    class << self
      attr_writer :config_file

      def config_class
      	subclasses_of(self).first || self
      end

      def config_file
	      @config_file || 'settings'
      end

      def load_and_parse
        process_options
        load_config_file
        apply_all
        validate
      end

      def set(name, value)
      	@temp_hash ||= {}
	      @temp_hash[name.to_s] = value
      end

      def apply(name, value)
      	@hash ||= {}
	      @hash[name.to_s] = value
      end

      def apply_all
	      @hash ||= {}
	      @hash.merge!(@temp_hash) if @temp_hash
      end

      def method_missing(method_id, *args)
        return nil unless @hash
        @hash[method_id.to_s]
      end

      def validate
	      # TODO: Check file perms
        if (pid_file.nil? or pid_file.empty? or File.directory?(pid_file))
          STDERR.puts "PID file must be a writable file"
          exit 1
        end
      end

      def process_options
        parse_options
      end
  
      def parse_options
        OptionParser.new do |opts|
          opts.on("-f", "--config [filename]", "Config file to use (default 'settings')") do |filename|
      	    self.config_file = filename
    	    end
          opts.on("-d", "--daemon", "Run in the background as a daemon") do
            self.set(:daemon, true)
          end
          opts.on("-l", "--debug-log [log-file]", "Debug Log File") do |log|
            self.set(log_file, log)
          end
	        yield opts if block_given?
	      end.parse!
      end

      private
        def load_config_file
          contents = ""
          File.open(config_file, "r") { |file| contents << file.read }
          contents.split("\n").each_with_index do |line, index|
            pair = line.split("=")
            if pair.size != 2
              STDERR.puts "Invalid config file '#{config_file}'. Syntax error at line #{index + 1}"
              exit 1
            end
            config_class.apply(pair[0].strip, pair[1].strip)
          end
        end

        def subclasses_of(*superclasses) #:nodoc:
          subclasses = []
          superclasses.each do |sup|
            ObjectSpace.each_object(Class) do |k|
              if superclasses.any? { |superclass| k < superclass } &&
               	(k.name.nil? || k.name.empty? || eval("defined?(::#{k}) && ::#{k}.object_id == k.object_id"))
  	            subclasses << k
              end
            end
            subclasses.uniq!
          end
          subclasses
        end
    end
  end
end
