module ActsAsActivityStream
  module Actorable
    def acts_as_actor
      class_eval do
        has_one :actor, as: :actorable, autosave: true, dependent: :destroy
        has_many :comments, :through => :actor
        has_many :likes, :through => :actor

        before_create :build_actor

        def to_builder
          Jbuilder.new do |json|
          end
        end

        def follow(subject)
          actor.follow(subject.actor)
        end

        alias_method :make_friend, :follow

        def unfollow(subject)
          actor.unfollow(subject.actor)
        end

        def unfriend(subject)
          actor.unfriend(subject.actor)
        end

        def has_friend?(subject)
          actor.has_friend?(subject.actor)
        end

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

        def suggestions(type = nil, size = 3, avoid_ids = [])
          actor.suggestions(type, size, avoid_ids).map(&:actorable)
        end

        # post a post with body data
        def post(body)
          Post.create!(sender_id: actor.id, body: body)
        end

        # # repost a post with body data
        # def repost(body, parent_id)
        #   transaction do
        #     p = Post.create!(sender_id: actor.id, body: body)
        #     p.activities.first.update_column(:parent_id, parent_id)
        #   end
        # end

        def like(activity)
          activity = Activity.find(activity) if activity.is_a?(Integer)
          return nil unless activity.can_read_by?(actor)
          activity.likes.create!(sender_id: actor.id)
        end

        def comment(activity, body)
          activity = Activity.find(activity) if activity.is_a?(Integer)
          return nil unless activity.can_read_by?(actor)
          activity.comments.create!(sender_id: actor.id, body: body)
        end

        def wall(type, options = {})
          actor.wall(type, options)
        end
      end

    end
  end
end