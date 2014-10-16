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
      json.receiver       receiver
      # if parent
      #   json.parent_sender  parent.sender.to_builder.attributes!
      # end
      if to_activity?
        json.comments      flat_children.sort { |a,b| a.created_at <=> b.created_at}
                                        .collect { |a| a.to_builder.attributes! }
      end
    end
  end

  #final target of comment
  def final_obj
    obj = self
    while obj.to_comment?
      obj = self.commentable
    end
    obj.commentable
  end

  def to_activity?
    commentable.class.name == 'Activity'
  end

  def to_comment?
    commentable.class.name == 'Comment'
  end

  def flat_children
    arr = children.to_ary
    children.each do |a|
      a.flat_children.each do |b|
        arr.push b
      end
    end
    arr
  end

  private

  def init_title
    title ||= body.truncate(60, :separator =>' ')
  end

  def has_children?
    !children.blank?
  end

  def has_parent?
    !parent.nil?
  end

  def receiver
    if to_activity?
      commentable.author.to_builder.attributes!
    elsif to_comment?
      commentable.sender.to_builder.attributes!
    end
  end
end
