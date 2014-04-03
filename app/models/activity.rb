# Activities follow the {Activity Streams}[http://activitystrea.ms/] standard.
#
# Every {Activity} has an {#author}
#
# author:: Is the {actorable} that originated
#          the activity. The entity that posted something, liked, etc..
#
# Only friends(Facebook) or followers(Twitter) will be able to reach the {Activity}
#
class Activity < ActiveRecord::Base

  belongs_to :author,
             :class_name => "Actor"

  belongs_to :activable, :polymorphic => true

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  scope :authored_by, lambda { |actor_id|
    where(:author_id => actor_id)
  }

  scope :with_verb, lambda {|verb|
    where(:verb => verb)
  }

  validates_presence_of :author_id

  def to_builder
    Jbuilder.new do |json|
      json.id             id
      json.type           activable_type
      json.verb           verb
      json.target         data
      json.author         author.actorable.to_builder.attributes!
      json.likes_count    likes_count
      json.comments_count comments_count
      json.created_at     created_at
      json.updated_at     updated_at
    end
  end

  # The {actorable} author
  def author_subject
    author.subject
  end

  # Does this {Activity} could be read by an actor
  def can_read_by?(actor)
    return true unless ActsAsActivityStream.sns_type == :custom
    author.has_friend?(actor)
  end

  # JSON data of the activable
  # This is the core part of viewing an activity
  def data
    if activable
      activable.activity_data(verb) ||
        activable.default_activity_data(verb)
    end
  end

end
