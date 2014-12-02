class Comment < ActiveRecord::Base

  belongs_to :sender, :class_name  => 'Actor'
  belongs_to :commentable, polymorphic: true
  belongs_to :activity, foreign_key: :commentable_id, class_name: "Activity", counter_cache: true
  belongs_to :parent, class_name: "Comment"
  has_many :children, class_name: "Comment", as: :commentable, dependent: :destroy


  validates_presence_of :body

  before_save :init_title

  def to_builder
    Jbuilder.new do |json|
      json.id             id
      json.body           body
      json.sender         sender.to_builder.attributes!
      json.sender_time    created_at
      if parent
        json.receiver  parent.sender.to_builder.attributes!
      end
    end
  end


  private

  def init_title
    title ||= body.truncate(60, :separator =>' ')
  end

end
