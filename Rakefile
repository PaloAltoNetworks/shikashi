require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rubygems/package_task'
require 'rake/testtask'

Rake::TestTask.new do |task|
  task.libs << 'test'
  task.test_files = FileList['spec/*_spec.rb', 'spec/**/*_spec.rb']
end

desc 'Generate RDoc'
Rake::RDocTask.new :rdoc do |rd|
  rd.rdoc_dir = 'doc'
  rd.rdoc_files.add 'lib', 'README'
  rd.main = 'README'
end

desc 'Clean up'
task :clean => [ :clobber_rdoc, :clobber_package ]

desc 'Clean up'
task :clobber => [ :clean ]
