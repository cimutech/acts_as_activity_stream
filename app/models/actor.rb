# An {Actor} represents a social entity. This means {User individuals},
# but also {Group groups}, departments, organizations even nations or states.
#
# Actors are the nodes of a social network. Two actors are linked by {Tie Ties}. The
# type of a {Tie} is a {Relation}. Each actor can define and customize their relations own
# {Relation Relations}.
#
# Every {Actor} has an Avatar, a {Profile} with personal or group information, contact data, etc.
#
# {Actor Actors} perform {ActivityAction actions} (like, suscribe, etc.) on
# {ActivityObject activity objects} ({Post posts}, {Comment commments}, pictures, events..)
#
# = Actor subtypes
# An actor subtype is called a {SocialStream::Models::Subject Subject}.
# {SocialStream::Base} provides two actor subtypes, {User} and {Group}, but the
# application developer can define as many actor subtypes as required.
# Besides including the {SocialStream::Models::Subject} module, Actor subtypes
# must added to +config/initializers/social_stream.rb+
#
#
class Actor < ActiveRecord::Base

  # acts_as_activable

  belongs_to :actorable, polymorphic: true

  has_many :sent_contacts,
           :class_name  => 'Contact',
           :foreign_key => 'sender_id',
           :dependent   => :destroy

  has_many :received_contacts,
           :class_name  => 'Contact',
           :foreign_key => 'receiver_id',
           :dependent   => :destroy

  has_many :senders,
           :through => :received_contacts,
           :uniq => true

  has_many :receivers,
           :through => :sent_contacts,
           :uniq => true

  has_many :authored_activities,
           :class_name  => "Activity",
           :foreign_key => :author_id,
           :dependent   => :destroy
  has_many :owned_activities,
           :class_name  => "Activity",
           :foreign_key => :owner_id,
           :dependent   => :destroy

  scope :with_type, lambda { |type|
    where(:avatarable_type => type)
  }

  def subject
    actorable
  end

  # follows
  def followers
    senders
  end

  # followings
  def followings
    receivers
  end

  # friends
  # make contact to each other
  def friends
    senders.where("actors.id in (?)", receivers)
  end

  # Return a contact to actor.
  def contact_to(actor)
    sent_contacts.received_by(actor.id).first
  end

  # Return a contact to subject. Create it if it does not exist
  def contact_to!(actor, blocked = true)
    contact_to(actor) ||
      sent_contacts.create!(receiver: actor, blocked: blocked)
  end

  def follow(actor)
    contact_to!(actor, true)
  end
  alias_method :make_friend, :follow

  # The {Contact} of this {Actor} to self (totally close!)
  def self_contact
    contact_to!(self, true)
  end

  alias_method :ego_contact, :self_contact

  # An array with the ids of {Actor Actors} followed by this {Actor}
  # plus the id from this {Actor}
  def following_and_self_ids
    sender_ids + [ id ]
  end

  # By now, it returns a suggested {Contact} to another {Actor}
  #
  # @return [Contact]
  def suggestions(type = nil, size = 1, avoid_ids = [])
    avoid_ids += following_and_self_ids
    candidates = Actor.where(Actor.arel_table[:id].not_in(avoid_ids))
    candidates = candidates.with_type(type) unless type.nil?

    size.times.map {
      candidates.delete_at rand(candidates.size)
    }
  end

  def pending_contacts
    received_contacts.not_reflexive.pending
  end

  def pending_contacts?
    pending_contacts_count > 0
  end

  def pending_friends
    pending_contacts.map(&:sender)
  end

  # The set of {Activity activities} in the wall of this {Actor}.
  #
  # There are two types of walls:
  # home:: includes all the {Activity activities} from this {Actor} and their followed {Actor actors}
  #             See {Permission permissions} for more information on the following support
  # profile:: The set of activities in the wall profile of this {Actor}, it includes only the
  #           activities from the ties of this actor that can be read by the subject
  #
  # Options:
  # :for:: the subject that is accessing the wall
  # :relation:: show only activities that are attached at this relation level. For example,
  #             the wall for members of the group.
  #
  def wall(type, options = {})
    options[:for] = self if type == :home

    wall =
      Activity.
        select("DISTINCT activities.*").
        roots.
        includes(:author, :user_author, :owner, :activity_objects, :activity_verb, :relations)

    actor_ids =
      case type
      when :home
        following_actor_and_self_ids
      when :profile
        id
      else
        if options[:actor_ids].nil?
          raise "Unknown type of wall without actor_ids: #{ type }"
        else
          options[:actor_ids]
        end
      end

    wall = wall.authored_or_owned_by(actor_ids)

    # Authentication
    wall = wall.shared_with(options[:for])

    wall = wall.order("id desc")
  end

  # Use slug as parameter
  def to_param
    slug
  end

  private

  def unread_messages_count
    mailbox.inbox(:unread => true).count(:id, :distinct => true)
  end
end
