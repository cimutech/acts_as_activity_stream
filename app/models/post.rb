class Post < ActiveRecord::Base
  acts_as_activity

  validates_presence_of :body

  belongs_to :sender, :class_name  => 'Actor'

  after_create :create_post_activity
  before_save :init_title

  def create_post_activity
    send_activity(sender_id, 'post')
  end

  def activity
    activities.first
  end

  def to_builder
    Jbuilder.new do |json|
      json.id        id
      json.title     title
      json.body      body
    end
  end

  private

  def init_title
    title ||= body.truncate(60, :separator =>' ')
  end

end