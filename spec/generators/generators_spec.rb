require 'generators_helper'

# Generators are not automatically loaded by Rails
require 'generators/acts_as_activity_stream/install_generator'

describe ActsAsActivityStream::InstallGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../tmp", __FILE__)
  teardown :cleanup_destination_root

  before {
    prepare_destination
  }

  def cleanup_destination_root
    FileUtils.rm_rf destination_root
  end

  describe 'generator' do
    before {
      run_generator
    }

    describe 'config/initializers/acts_as_activity_stream.rb' do
      subject { file('config/initializers/acts_as_activity_stream.rb') }

      it { should exist }
    end

    describe 'migration file' do
      subject { migration_file('db/migrate/create_acts_as_activity_stream.rb') }

      it { should be_a_migration }
      it { should contain "create_table :activities" }
      it { should contain "create_table :actors" }
      it { should contain "create_table :contacts" }
      it { should contain "create_table :posts" }
      it { should contain "create_table :likes" }
      it { should contain "create_table :comments" }
    end
  end

end
