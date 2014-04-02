require 'rails/generators/active_record'
class ActsAsActivityStream::InstallGenerator < ActiveRecord::Generators::Base
  # include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer_file
    template 'initializer.rb', 'config/initializers/acts_as_activity_stream.rb'
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_acts_as_activity_stream.rb'
  end
end