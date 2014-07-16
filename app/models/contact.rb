# A {Contact} is an ordered pair of {Actor Actors},
#
# {Contact Contacts} is a link between two actors
# Sent a unblocked contact to an actor, means you follow/make friend to this actor.
# A blocked contact does not mean anything.
#
# == Inverse Contacts
#
# Alice has a {Contact} to Bob. The inverse is the {Contact} from {Bob} to {Alice}.
# Inverse contacts are used to check if contacts are replied, for instance, if Bob added
# Alice as contact after she did so.
#
# Again, the Contact from Bob to Alice must have positive {not blocked} to be active.
#
class Contact < ActiveRecord::Base

  belongs_to :inverse, class_name: "Contact"

  belongs_to :sender, class_name: "Actor"
  belongs_to :receiver, class_name: "Actor"

  scope :not_blocked, -> { where(blocked: false) }

  scope :pending, -> { where(blocked: true) }

  scope :sent_by, lambda { |s_id| where(sender_id: s_id)}

  scope :received_by, lambda { |r_id| where(receiver_id: r_id)}

  scope :sent_or_received_by, lambda { |a_id|
    where(arel_table[:sender_id].eq(a_id).
          or(arel_table[:receiver_id].eq(a_id)))
  }

  scope :recent, -> { order("contacts.created_at DESC") }

  scope :not_reflexive, -> { where(arel_table[:sender_id].not_eq(arel_table[:receiver_id])) }

  before_save  :validate_self_contact
  after_create :create_reverse_contact

  def sender_subject
    sender.subject
  end

  def receiver_subject
    receiver.subject
  end

  # Does this {Contact} have the same sender and receiver?
  def reflexive?
    sender_id == receiver_id
  end

  # Find or create the inverse {Contact}
  def inverse!
    inverse || create_reverse_contact
  end

  # The {Contact} in the other way is established
  def replied?
    not inverse!.blocked
  end

  private

  def validate_self_contact
    errors.add(:sender_id, "is invalid. Should not contact to self!" ) if sender_id == receiver_id
  end

  def create_reverse_contact
    if not inverse_id.present?
      c = Contact.where(sender_id: self.receiver_id, receiver_id: self.sender_id).first
      c ||= Contact.create!(sender_id: self.receiver_id, receiver_id: self.sender_id, inverse_id: self.id)
      self.update_column(:inverse_id, c.id)
    end
  end
end
