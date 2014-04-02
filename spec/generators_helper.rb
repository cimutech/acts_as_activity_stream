require 'rubygems'
require "bundler/setup"

require 'rails'
require 'coveralls'
Coveralls.wear_merged!

require 'active_record/railtie'

module TestApp
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__)
  end
end

require 'ammeter/init'