
module ActsAsActivityStream
  class Engine < ::Rails::Engine
    config.app_generators.messages :mailboxer

    initializer "acts_as_activity_stream.mailboxer", :before => :load_config_initializers do
      Mailboxer.setup do |config|
        # config.email_method = :subject_mailboxer_email
      end
    end
  end
end