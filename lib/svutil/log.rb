module SVUtil
  class Log
    class << self
      %w(info warning error).each do |level|
        define_method(level) do |arg|
          log(level, arg)
        end
      end

      def log(level, arg)
	      STDOUT.puts "#{Time.now}: (#{level}) #{arg}"
      end
    end
  end
end
