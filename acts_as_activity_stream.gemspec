$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_activity_stream/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_activity_stream"
  s.version     = ActsAsActivityStream::VERSION
  s.authors     = ["chen qing hua"]
  s.email       = ["chenqh@cimu.com.cn"]
  s.homepage    = "TODO"
  s.summary     = "Basic features to build a social network"
  s.description = "ActsAsActivityStream is a Ruby on Rails engine providing social network with activity streams. "

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"

  s.add_development_dependency "sqlite3"

  # Slug generation
  # s.add_runtime_dependency('stringex', '~> 2.4.0')
  # activerecord hacker
  # s.add_runtime_dependency('squeel', '~> 1.1.1')
  # Messages
  s.add_runtime_dependency('mailboxer','~> 0.11.0')
  # Strong Parameters
  s.add_runtime_dependency('strong_parameters','~> 0.2.0')
  # Specs
  s.add_development_dependency('rspec-rails', '~> 2.8.1')
  # Fixtures
  s.add_development_dependency('factory_girl', '~> 4.4.0')
  # Continous integration
  s.add_development_dependency('ci_reporter', '~> 1.6.4')
  # pry
  s.add_development_dependency('pry-rails','~> 0.3.2')
end
