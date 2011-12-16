require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

module SVUtil
  def self.config
    Config.config_class
  end

  class Defaults
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
    class << self
      attr_writer :config_file
      attr_reader :attrs
      attr_reader :defaults
      # Used mainly for testing
      attr_accessor :option_source

      def config_class
      	subclasses_of(self).first || self
      end

      def config_file
	      @config_file || 'settings'
      end

      def set(options = {})
        @attrs ||= {}
        if block_given?
          yield self
        end
        self.validate
      end

      def defaults(&block)
        @defaults ||= Defaults.new
        yield @defaults
      end

      def validate
	      # TODO: Check file perms
        if (pid_file.nil? or pid_file.empty? or File.directory?(pid_file))
          STDERR.puts "PID file must be a writable file"
          exit 1
        end
        true
      end

      def init
        self.set do |c|
          process_options
          if File.exists?("settings") || self.config_file
            load_config_file
          end
        end
      end

      protected
        # Overide in subclasses for additional options
        def process_options
          parse_options
        end

        def parse_options(&block)
          OptionParser.new do |opts|
            opts.on("-f", "--config [filename]", "Config file to use (default 'settings')") do |filename|
              self.config_file = filename.strip
            end
            opts.on("-d", "--daemon", "Run in the background as a daemon") do
              self.daemon = true
            end
            opts.on("-l", "--debug-log [log-file]", "Debug Log File") do |log|
              self.log_file = log
            end
            opts.on("-T", "--trace", "Display backtrace on errors") do
              self.trace = true
            end
            yield opts if block_given?
          end.parse!(self.option_source || ARGV)
        end

      private
        def method_missing(method_id, *args)
          @attrs ||= {}
          if method_id.to_s =~ /=$/
            @attrs[method_id.to_s[0...-1]] = args.first
          else
            value = @attrs[method_id.to_s]
            if !value && @defaults
              @defaults.default_for(method_id.to_s)
            else
              value
            end
          end
        end

        def load_config_file
          contents = ""
          File.open(config_file, "r") { |file| contents << file.read }
          contents.split("\n").each_with_index do |line, index|
            pair = line.split("=")
            if pair.size != 2
              STDERR.puts "Invalid config file '#{config_file}'. Syntax error at line #{index + 1}"
              exit 1
            end
            self.send("#{pair[0].strip}=", pair[1].strip)
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
