module ActsAsActivityStream
  module Actorable
    def acts_as_actor
      class_eval do
        has_one :actor, as: :actorable, autosave: true, dependent: :destroy

        before_create :build_actor

        def follow(subject)
          actor.follow(subject.actor)
        end

        alias_method :make_friend, :follow

        def followers
          actor.followers.map(&:actorable)
        end

        def followings
          actor.followings.map(&:actorable)
        end

        def friends
          actor.friends.map(&:actorable)
        end

        def pending_friends
          actor.pending_friends.map(&:actorable)
        end

        def wall(type, options = {})

        end
      end

      define_method "#{self.class.name}_suggestions" do |size = 3, options = {}|
        actor.suggestion(self.class.name, size, options).map(&:actorable)
      end

    end
  end
end