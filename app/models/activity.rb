# Activities follow the {Activity Streams}[http://activitystrea.ms/] standard.
#
# Every {Activity} has an {#author}, {#user_author} and {#owner}
#
# author:: Is the {SocialStream::Models::Subject subject} that originated
#          the activity. The entity that posted something, liked, etc..
#
# user_author:: The {User} logged in when the {Activity} was created.
#               If the {User} has not changed the session to represent
#               other entity (a {Group} for example), the user_author
#               will be the same as the author.
#
# owner:: The {SocialStream::Models::Subject subject} whose wall was posted
#         or comment was liked, etc..
#
# == {Audience Audiences} and visibility
# Each activity is attached to one or more {Relation relations}, which define
# the {SocialStream::Models::Subject subject} that can reach the activity
#
# In the case of a {Relation::Public public relation} everyone will be
# able to see the activity.
#
# In the case of {Relation::Custom custom relations}, only the subjects
# that have a {Tie} with that relation (in other words, the contacts that
# have been added as friends with that relation} will be able to reach the {Activity}
#
class Activity < ActiveRecord::Base

  belongs_to :author,
             :class_name => "Actor"
  belongs_to :owner,
             :class_name => "Actor"

  belongs_to :activable, :polymorphic => true

  # has_many :comments

  scope :authored_by, lambda { |subject|
    where(:author_id => Actor.normalize_id(subject))
  }
  scope :owned_by, lambda { |subject|
    where(:owner_id => Actor.normalize_id(subject))
  }

  scope :shared_with, lambda {|subject|
    where(:owner_id => subject.friends_id)
  }

  validates_presence_of :author_id, :owner_id

  # The {SocialStream::Models::Subject subject} author
  def author_subject
    author.subject
  end

  # The {SocialStream::Models::Subject subject} owner
  def owner_subject
    owner.subject
  end

  # The {SocialStream::Models::Subject subject} user actor
  def user_author_subject
    user_author.subject
  end

  # Does this {Activity} have the same sender and receiver?
  def reflexive?
    author_id == owner_id
  end

  # Is the author represented in this {Activity}?
  def represented_author?
    author_id != user_author_id
  end

  # The {Actor} author of this activity
  #
  # This method provides the {Actor}. Use {#sender_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def sender
    author
  end

  # The {SocialStream::Models::Subject Subject} author of this activity
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#sender} for the {Actor}.
  def sender_subject
    author_subject
  end

  # The wall where the activity is shown belongs to receiver
  #
  # This method provides the {Actor}. Use {#receiver_subject} for the {SocialStream::Models::Subject Subject}
  # ({User}, {Group}, etc..)
  def receiver
    owner
  end

  # The wall where the activity is shown belongs to the receiver
  #
  # This method provides the {SocialStream::Models::Subject Subject} ({User}, {Group}, etc...).
  # Use {#receiver} for the {Actor}.
  def receiver_subject
    owner_subject
  end

  def data
    activable.activity_data(verb) ||
      activable.default_activity_data(verb)
  end

end
