# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), *%w[lib/clickatell/version])

$gemspec = Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  
  s.name                = %q{clickatell}
  s.version             = Clickatell::VERSION.to_s
  s.summary             = "Ruby interface to the Clickatell SMS gateway service."
  s.author              = "Luke Redpath"
  s.email               = "luke@lukeredpath.co.uk"
  s.homepage            = "http://clickatell.rubyforge.org"
  s.date                = %q{2009-10-07}
  s.default_executable  = %q{sms}
  s.executables         = ["sms"]
  s.extra_rdoc_files    = ["RDOC_README.txt", "History.txt", "License.txt"]
  s.files               = ["History.txt", "License.txt", "RDOC_README.txt", "README.textile", "bin/sms", "spec/api_spec.rb", "spec/command_executor_spec.rb", "spec/hash_ext_spec.rb", "spec/response_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "lib/clickatell", "lib/clickatell/api", "lib/clickatell/api/command.rb", "lib/clickatell/api/command_executor.rb", "lib/clickatell/api/error.rb", "lib/clickatell/api/message_status.rb", "lib/clickatell/api.rb", "lib/clickatell/response.rb", "lib/clickatell/utility", "lib/clickatell/utility/options.rb", "lib/clickatell/utility.rb", "lib/clickatell/version.rb", "lib/clickatell.rb", "lib/core-ext", "lib/core-ext/hash.rb"]
  s.has_rdoc            = true
  s.rdoc_options        = ["--main", "RDOC_README.txt"]
  s.require_paths       = ["lib"]
  s.rubyforge_project   = %q{clickatell}
  s.rubygems_version    = %q{1.3.1}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
