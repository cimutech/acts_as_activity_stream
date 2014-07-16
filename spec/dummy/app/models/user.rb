
class User < ActiveRecord::Base
  acts_as_actor

  validates_presence_of :email

  def to_builder
    Jbuilder.new do |json|
      json.id    id
      json.name  name
      json.email email
    end
  end

end
