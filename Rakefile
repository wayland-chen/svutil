%w[rubygems rake rake/clean hoe fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/svutil'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('svutil') do |p|
  p.version = SVUtil::VERSION
  p.developer('Daniel Draper', 'daniel@netfox.com')
  p.summary = "Simple Process Builder for Ruby"
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
  p.readme_file = "README.rdoc"
  p.require_ruby_version(">= 1.9.0")
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
