$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'svutil/config'
require 'svutil/log'
require 'svutil/process_manager'

module SVUtil
  VERSION = '0.9.9'
end
