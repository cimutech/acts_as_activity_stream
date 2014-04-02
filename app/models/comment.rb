class Comment < ActiveRecord::Base

  belongs_to :sender, :class_name  => 'Actor'
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent, class_name: "Comment"
  has_many   :children, class_name: "Comment"

  validates_presence_of :body

  before_save :init_title

  def to_builder
    Jbuilder.new do |json|
      json.id             id
      json.body           body
      json.sender         sender.to_builder.attributes!
      if parent
        json.parent_sender  parent.sender.to_builder.attributes!
      end
    end
  end

  private

  def init_title
    title ||= body.truncate(60, :separator =>' ')
  end

end
