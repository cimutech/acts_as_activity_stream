require 'acts_as_activity_stream/test_helpers/migration'

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.drop_table t
end

ActsAsActivityStream::TestHelpers::Migration.new.up

require File.expand_path("../../dummy/db/seeds", __FILE__)
