# An {Actor} represents a social entity. This means {User individuals},
# but also groups, departments, organizations even nations or states.
#
# Actors are the nodes of a social network. Two actors are linked by {contact}.
#
# {Actor Actors} post the {Activable}(like post), and send specified activity by {Activable}.
#
class Actor < ActiveRecord::Base

  belongs_to :actorable, polymorphic: true

  has_many :comments,
           :class_name  => 'Comment',
           :foreign_key => 'sender_id',
           :dependent   => :destroy
  has_many :posts,
           :class_name  => 'Post',
           :foreign_key => 'sender_id',
           :dependent   => :destroy
  has_many :likes,
           :class_name  => 'Like',
           :foreign_key => 'sender_id',
           :dependent   => :destroy

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

  has_many :unblocked_senders,
           :through => :received_contacts,
           :source  => :sender,
           :conditions => { "contacts.blocked" => false },
           :uniq => true

  has_many :receivers,
           :through => :sent_contacts,
           :uniq => true

  has_many :unblocked_receivers,
           :through => :sent_contacts,
           :source  => :receiver,
           :conditions => { "contacts.blocked" => false },
           :uniq => true

  has_many :authored_activities,
           :class_name  => "Activity",
           :foreign_key => :author_id,
           :dependent   => :destroy

  scope :with_type, lambda { |type|
    where(:actorable_type => type)
  }

  def to_builder
    Jbuilder.new do |json|
      json.id             id
      json.type           actorable_type
      json.subject        actorable.to_builder.attributes!
    end
  end

  def subject
    actorable
  end

  # follows
  def followers
    unblocked_senders
  end

  # followings
  def followings
    unblocked_receivers
  end

  # friends
  # make contact to each other
  def friends
    unblocked_senders.where("actors.id in (?)", unblocked_receivers)
  end

  # check if an actor is a friend to current actor
  def friend_to?(actor)
    return true if actor == self
    !self.contact_to!(actor).blocked && !actor.contact_to!(self).blocked
  end

  # Return a contact to actor.
  def contact_to(actor)
    sent_contacts.received_by(actor.id).first
  end

  # Return a contact to subject. Create it if it does not exist
  def contact_to!(actor)
    contact_to(actor) || sent_contacts.create!(receiver: actor)
  end

  def follow(actor)
    contact = contact_to!(actor)
    contact.update_column(:blocked, false)
    contact
  end
  alias_method :make_friend, :follow

  # actor who share activity to this actor
  # with sns like twitter, followings will be the sharers
  # with sns like facebook, friends will be the sharers
  # and of course, sharers should include actor self
  def sharer_ids
    if ActsAsActivityStream.sns_type == :follow
      followings.map(&:id) + [self.id]
    else
      friends.map(&:id) + [self.id]
    end
  end

  # An array with the ids of {Actor Actors} followed by this {Actor}
  # plus the id from this {Actor}
  def following_and_self_ids
    unblocked_receiver_ids + [ id ]
  end

  # By now, it returns a suggested {Contact} to another {Actor}
  #
  # @return [Contact]
  def suggestions(type = nil, size = 1, avoid_ids = [])
    avoid_ids += following_and_self_ids
    candidates = Actor.where(Actor.arel_table[:id].not_in(avoid_ids))
    candidates = candidates.with_type(type) unless type.nil?

    if candidates.size > size
      size.times.map {
        candidates.delete_at rand(candidates.size)
      }
    else
      candidates
    end
  end

  def pending_contacts
    sent_contacts.not_reflexive.pending
  end

  def pending_contacts?
    pending_contacts_count > 0
  end

  def pending_friends
    pending_contacts.map(&:receiver)
  end

  # The set of {Activity activities} in the wall of this {Actor}.
  #
  # There are two default types of walls:
  # home:: includes all the {Activity activities} from this {Actor} and their followed {Actor actors}
  #
  # profile:: The set of activities in the wall profile of this {Actor}, it includes only the
  #           activities from this actor
  #
  # Options:
  # :actor_ids:: activities from specify actors
  #
  def wall(type = nil, options = {})
    actor_ids =
      case type
      when :home
        sharer_ids
      when :profile
        id
      else
        if options[:actor_ids].nil?
          raise "Unknown type of wall without actor_ids: #{ type }"
        else
          options[:actor_ids].reject{|a| if not sharer_ids.include?(a) then a end}
        end
      end
    wall = Activity.includes(:activable, :author => :actorable).authored_by(actor_ids).order("id desc")
  end

  # Use slug as parameter
  def to_param
    slug
  end

  def unread_messages_count
    mailbox.inbox(:unread => true).count(:id, :distinct => true)
  end
end
