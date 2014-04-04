# Gem's dependencies
require 'acts_as_activity_stream/dependencies'

require "acts_as_activity_stream/actorable"
require "acts_as_activity_stream/activable"

module ActsAsActivityStream
  mattr_accessor :sns_type
  @@sns_type = :custom ## or follow

  mattr_accessor :actor_types
  @@actor_types = [] # :user

  mattr_accessor :activity_types
  @@activity_types = [:post] # :post

  class << self
    def setup
      yield self
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActsAsActivityStream::Actorable
  ActiveRecord::Base.extend ActsAsActivityStream::Activable
end

require 'acts_as_activity_stream/engine'