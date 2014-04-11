require 'rails/generators'
require 'rails/generators/migration'

class ActsAsActivityStream::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_initializer_file
    template 'initializer.rb', 'config/initializers/acts_as_activity_stream.rb'
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_acts_as_activity_stream.rb'
  end
end