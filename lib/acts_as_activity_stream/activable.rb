module ActsAsActivityStream
  module Activable
    def acts_as_activable(options = {})
      class_eval do
        has_one :activities, as: :activable, :dependent => :destroy

        def send_activity(author_id, owner_id, verb = "", notification = false)
          activities.create!(verb: verb, author_id: author_id, owner_id: owner_id)
        end

        def send_notification
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
          case verb
          when 'post'
            {id: id, title: send("title"), description: send("description")}
          when 'like'
            {id: id, title: send("title")}
          else
            raise "Invalid verb"
          end
        end
      end
      target_method_name = options[:target].nil? ? "self" : options[:target].to_s

      define_method "target" do
         send(target_method_name)
      end
    end

  end
end