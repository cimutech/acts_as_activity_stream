
class User < ActiveRecord::Base
  acts_as_actor

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email

  validates_presence_of :email

  def to_builder
    Jbuilder.new do |json|
      json.id    id
      json.name  name
      json.email email
    end
  end

end
