module ActsAsActivityStream
  module Activable
    def acts_as_activity
      class_eval do
        has_many :activities, as: :activable, :dependent => :destroy

        def to_builder
          Jbuilder.new do |json|
          end
        end

        def send_activity(author_id, verb = "", notification = false)
          activities.create!(verb: verb, author_id: author_id)
        end

        # return activity data with verb for activity
        # different verb might need different data
        # eg: A post include title and description
        # with verb => 'post'
        # activity: {ted} post a article name {title}
        # part of {description}
        # with verb => 'like'
        # activity: {jhon} like a post {title}
        def activity_data(verb = nil)
        end

        def default_activity_data(verb = nil)
          verb.nil? ? raise("Invalid verb") : to_builder.attributes!
        end
      end
    end

  end
end