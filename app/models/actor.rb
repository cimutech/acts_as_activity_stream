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
           -> {uniq},
           :through => :received_contacts


  has_many :unblocked_senders,
           -> { where(:"contacts.blocked" => false).uniq },
           :through => :received_contacts,
           :source  => :sender

  has_many :receivers,
           -> {uniq},
           :through => :sent_contacts

  has_many :unblocked_receivers,
           -> { where(:"contacts.blocked" => false).uniq },
           :through => :sent_contacts,
           :source  => :receiver

  has_many :authored_activities,
           :class_name  => "Activity",
           :foreign_key => :author_id,
           :dependent   => :destroy

  scope :with_type, -> (type) { where(:actorable_type => type.to_s.camelize) unless type.nil?}

  ActsAsActivityStream.actor_types.each do |type|
    belongs_to type.to_sym, foreign_key: :actorable_id, class_name: type.to_s.camelize
  end

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

  def followers
    unblocked_senders
  end

  # check if an actor is following current actor
  def has_follower?(actor)
    return true if actor == self
    !actor.contact_to!(self).blocked
  end

  def followings
    unblocked_receivers
  end

  # check if an actor is followed by current actor
  def has_following?(actor)
    return true if actor == self
    !self.contact_to!(actor).blocked
  end

  # friends
  # make contact to each other
  def friends
    current_id = self.id
    # received_contacts => contacts, and inverse => inverses_conteacts
    Actor.joins(:received_contacts => :inverse).where(:contacts => {:blocked => false, :sender_id => current_id},
                                                      :inverses_contacts => {:blocked => false})
    # Actor.joins{received_contacts.inverse}.where{
    #   (received_contacts.inverse.blocked.eq false) &
    #   (received_contacts.blocked.eq false) &
    #   (received_contacts.sender_id.eq current_id)
    # }
  end

  # check if an actor is a friend to current actor
  def has_friend?(actor)
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

  # remove friendship between two actor
  def unfollow(actor)
    contact = contact_to!(actor)
    contact.update_column(:blocked, true)
    contact
  end

  # remove friendship between two actor
  def unfriend(actor)
    unfollow(actor)
    actor.unfollow(self) if ActsAsActivityStream.sns_type == :custom
  end

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

  def pending_friends
    current_id = self.id
    Actor.joins(:received_contacts => :inverse).where(:contacts => {:blocked => true, :sender_id => current_id},
                                                      :inverses_contacts => {:blocked => false})
    # Actor.joins{received_contacts.inverse}.where{
    #   (received_contacts.inverse.blocked.eq false) &
    #   (received_contacts.blocked.eq true) &
    #   (received_contacts.sender_id.eq current_id)
    # }
  end

  def requested_friends
    current_id = self.id
    Actor.joins(:received_contacts => :inverse).where(:contacts => {:blocked => false, :sender_id => current_id},
                                                      :inverses_contacts => {:blocked => true})
    # Actor.joins{received_contacts.inverse}.where{
    #   (received_contacts.inverse.blocked.eq true) &
    #   (received_contacts.blocked.eq false) &
    #   (received_contacts.sender_id.eq current_id)
    # }
  end

  # The set of {Activity activities} in the wall of this {Actor}.
  #
  # There are three default types of walls:
  # home:: includes all the {Activity activities} from this {Actor} and their followed {Actor actors}
  #
  # profile:: The set of activities in the wall profile of this {Actor}, it includes only the
  #           activities from this actor

  # custom:: custom actor_ids passed by options[:actor_ids]

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
      when :custom
        options[:actor_ids]
      else
        if options[:actor_ids].nil?
          raise "Unknown type of wall without actor_ids: #{ type }"
        else
          options[:actor_ids].reject{|a| if not sharer_ids.include?(a) then a end}
        end
      end
    wall = Activity.includes(:activable, :author => :actorable).authored_by(actor_ids).order("id desc")
  end

end
