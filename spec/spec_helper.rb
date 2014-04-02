# Configure Rails Envinronment
ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ENV"] = "#{ ENV["RAILS_ENV"] }_#{ ENV['DB'] }" if ENV['DB']

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load Factories
require 'factory_girl'
Dir["#{File.dirname(__FILE__)}/factories/*.rb", "#{File.dirname(__FILE__)}/../*/spec/factories/*.rb"].each {|f| require f}

require 'coveralls'
Coveralls.wear_merged!

RSpec.configure do |config|

  config.color_enabled = true

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before :suite do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each do
    DatabaseCleaner.clean
  end

  config.after :each do
    ActsAsActivityStream.sns_type = :custom
    DatabaseCleaner.clean
  end
end