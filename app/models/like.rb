class Like < ActiveRecord::Base

  belongs_to :likable, polymorphic: true
  belongs_to :activity, foreign_key: :likable_id, class_name: "Activity", counter_cache: true
  belongs_to :sender, :class_name  => 'Actor'

  def to_builder
    Jbuilder.new do |json|
      json.id             id
      json.sender         sender.to_builder.attributes!
    end
  end

end
