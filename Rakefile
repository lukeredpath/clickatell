require "rubygems"
require "rake/rdoctask"

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "clickatell"
    gemspec.summary = "Ruby interface to the Clickatell SMS gateway service."
    gemspec.email = "luke@lukeredpath.co.uk"
    gemspec.homepage = "http://clickatell.rubyforge.org"
    gemspec.authors = ["Luke Redpath"]
    gemspec.executables = %w{sms}
    gemspec.extra_rdoc_files = %w{RDOC_README.txt History.txt License.txt}
    gemspec.has_rdoc = true
    gemspec.rdoc_options = %w{--main RDOC_README.txt}
  end
  
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

task :default => :spec

require "spec"
require "spec/rake/spectask"

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = %w(--format specdoc --colour)
  t.libs = ["spec"]
end

Spec::Rake::SpecTask.new("spec_html") do |t|
  t.spec_opts = %w(--format html)
  t.libs = ["spec"]
end

Rake::RDocTask.new do |rd|
  rd.main = "RDOC_README.txt"
  rd.rdoc_files.include("lib/**/*.rb", *$gemspec.extra_rdoc_files)
  rd.rdoc_dir = "rdoc"
end

desc 'Generate website files'
task :website do
  Dir['website/**/*.txt'].each do |txt|
    sh %{ ruby scripts/txt2html #{txt} > #{txt.gsub(/txt$/,'html')} }
  end
  sh "rake -s spec_html > website/specs.html"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package]

begin
  require "rake/contrib/sshpublisher"
  namespace :rubyforge do
    
    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]
    
    namespace :release do
      desc "Release a new version of this gem"
      task :gem => [:package] do
        require 'rubyforge'
        rubyforge = RubyForge.new
        rubyforge.configure
        rubyforge.login
        rubyforge.userconfig['release_notes'] = $gemspec.summary
        path_to_gem = File.join(File.dirname(__FILE__), "pkg", "#{$gemspec.name}-#{$gemspec.version}.gem")
        puts "Publishing #{$gemspec.name}-#{$gemspec.version.to_s} to Rubyforge..."
        rubyforge.add_release($gemspec.rubyforge_project, $gemspec.name, $gemspec.version.to_s, path_to_gem)
      end
    
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc, :website] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )
 
        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/clickatell/" 
 
        Rake::SshDirPublisher.new(host, remote_dir, 'website').upload
        Rake::SshDirPublisher.new(host, File.join(remote_dir, 'rdoc'), 'rdoc').upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end