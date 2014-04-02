# Gem's dependencies
require 'acts_as_activity_stream/dependencies'

require "acts_as_activity_stream/actorable"
require "acts_as_activity_stream/activable"

module ActsAsActivityStream
  mattr_accessor :sns_type
  @@sns_type = :custom ## or follow
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend ActsAsActivityStream::Actorable
  ActiveRecord::Base.extend ActsAsActivityStream::Activable
end

require 'acts_as_activity_stream/engine'