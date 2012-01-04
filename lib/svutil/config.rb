require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

module SVUtil
  class Defaults
    attr_reader :attrs

    def initialize
      @attrs = {}
    end

    def default_for(name)
      @attrs[name]
    end

    private
      def method_missing(method_id, *args)
        @attrs ||= {}
        if method_id.to_s =~ /=$/
          @attrs[method_id.to_s[0...-1]] = args.first
        end
      end
  end

  class Config
    attr_writer :config_file
    attr_reader :attrs

    def initialize
      @cli_options = {}
      @attrs = if self.class.defaults
        self.class.defaults.attrs.clone
      else
        {}
      end
    end

    def set(options = {})
      if block_given?
        yield self
      end
      self.validate
    end

    def config_file
      @config_file ||= "settings"
    end

    # TODO: Put in module and extend
    class << self
      attr_reader :cli_option_handlers
      attr_reader :validate_block

      def defaults
        @defaults ||= Defaults.new
        yield @defaults if block_given?
        return @defaults
      end

      def handle_options(&block)
        @cli_option_handlers ||= []
        @cli_option_handlers << block
      end 

      def validator(&block)
        @validate_block = block
      end
    end

    def set_cli_option(option, value)
      @cli_options ||= {}
      @cli_options[option.to_s] = value
    end

    def validate
      # TODO: Check file perms
      if ((pid_file.nil? or pid_file.empty? or File.directory?(pid_file)) && self.daemon)
        err("PID file must be a writable file")
      end
      # TODO: Validate the writability of the log file
      self.instance_exec(self, &self.class.validate_block) unless self.class.validate_block.nil?
      true
    end

    def init(test_options = nil)
      set do |c|
        self.config_provided_on_cli = false
        OptionParser.new do |opts|
          opts.on("-f", "--config [filename]", "Config file to use (default 'settings')") do |filename|
            self.config_file = filename.strip
            self.config_provided_on_cli = true
          end
          opts.on("-d", "--daemon", "Run in the background as a daemon") do
            set_cli_option(:daemon, true)
          end
          opts.on("-l", "--debug-log [log-file]", "Debug Log File") do |log|
            set_cli_option(:log_file, log)
          end
          opts.on("-T", "--trace", "Display backtrace on errors") do
            set_cli_option(:trace, true)
          end
          opts.on("-P", "--pid [pid-file]", "PID File") do |pid|
            set_cli_option(:pid_file, pid)
          end
          # Handle CLI passed options
          (self.class.cli_option_handlers || []).each do |handler|
            self.instance_exec(opts, &handler)
          end
        end.parse!(test_options || ARGV)


        # Process the config file
        if (self.config_file && File.exists?(self.config_file)) || self.config_provided_on_cli
          load_config_file
        end

        # Finally apply any CLI options
        (@cli_options || {}).each do |(k,v)|
          @attrs[k.to_s] = v
        end
      end
    end

    private
      def method_missing(method_id, *args)
        if method_id.to_s =~ /=$/
          @attrs[method_id.to_s[0...-1]] = args.first
        else
          value = @attrs[method_id.to_s]
        end
      end

      def load_config_file
        contents = ""
        File.open(config_file, "r") { |file| contents << file.read }
        contents.split("\n").each_with_index do |line, index|
          pair = line.split("=")
          if pair.size != 2
            err("Invalid config file '#{config_file}'. Syntax error at line #{index + 1}")
          end
          self.send("#{pair[0].strip}=", pair[1].strip)
        end
      end

      # TODO: This should be moved out to a Validator class
      def err(message)
        STDERR.puts(message)
        exit 1
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
