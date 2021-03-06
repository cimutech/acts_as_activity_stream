module ActsAsActivityStream
  module TestHelpers
    class Migration
      def initialize
        @base_migration = find_migration 'acts_as_activity_stream'
      end

      def up
        # Run any available migration
        ActiveRecord::Migrator.migrate @base_migration
      end

      def down
        begin
          ActiveRecord::Migrator.migrate @base_migration, 0
        rescue
          puts "WARNING: Social Stream Base failed to rollback"
        end
      end

      protected

      def find_migration(gem)
        File.join([get_full_gem_path(gem)], 'spec/dummy/db/migrate')
      end

      def require_old_migration(gem,file_path)
        require File.join([get_full_gem_path(gem),file_path])
      end

      def get_full_gem_path(gem)
        if (Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.8.0'))
          return Gem::Specification.find_by_name(gem).full_gem_path
        else
          return Gem::GemPathSearcher.new.find(gem).full_gem_path
        end
      end
    end
  end
end
