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

        def friend_actors(type = nil)
          actor.friends.with_type(type)
        end

        def friends(type = nil)
          type ||= self.class.name
          actors = self.friend_actors
          self.class.joins{actor}.where{
            (actor.id.in actors.select("actors.id"))
          }
        end

        def pending_friend_actors(type = nil)
          actor.pending_friends.with_type(type)
        end

        def pending_friends(type = nil)
          type ||= self.class.name
          actors = self.pending_friend_actors
          self.class.joins{actor}.where{
            (actor.id.in actors.select("actors.id"))
          }
        end

        def has_friend?(subject)
          actor.has_friend?(subject.actor)
        end

        def follower_actors(type = nil)
          actor.followers.with_type(type)
        end

        def followers(type = nil)
          type ||= self.class.name
          actors = self.follower_actors
          self.class.joins{actor}.where{
            (actor.id.in actors.select("actors.id"))
          }
        end

        def has_follower?(subject)
          actor.has_follower?(subject.actor)
        end

        def following_actors(type = nil)
          actor.followings.with_type(type)
        end

        def followings(type = nil)
          type ||= self.class.name
          actors = self.following_actors
          self.class.joins{actor}.where{
            (actor.id.in actors.select("actors.id"))
          }
        end

        def has_following?(subject)
          actor.has_following?(subject.actor)
        end

        # return relationship another {user} or other actor
        # -1: self 0: friend 1: follower 2: following 3: no contact
        def relationship(another)
          if self == another
            return -1
          elsif has_friend?(another)
            return 0
          elsif has_follower?(another)
            return 1
          elsif has_following?(another)
            return 2
          else
            return 3
          end
        end

        # return suggestion friend
        # type of actor, default is current class type
        def suggestions(type = nil, size = 3, avoid_actor_ids = [])
          actor.suggestions(type || self.class.name, size, avoid_actor_ids).map(&:actorable)
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