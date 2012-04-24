# -*- encoding: utf-8 -*-
#$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_data_owner/version"

Gem::Specification.new do |s|
  s.name          = %q{acts_as_data_owner}
  s.version       = ActsAsDataOwner::VERSION
  s.platform      = Gem::Platform::RUBY
  s.homepage      = %q{http://worldalias.com}
  s.authors       = ["Belorusov Dmitriy"]
  s.email         = ["Develby@gmail.com"]
  s.description   = %q{The Access Data framework for Ruby on Rails.}
  s.summary       = %q{The Access Data framework for Ruby on Rails.}

  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_paths = ["lib"]

  s.add_dependency("rails", ">= 3.0.0")

end




