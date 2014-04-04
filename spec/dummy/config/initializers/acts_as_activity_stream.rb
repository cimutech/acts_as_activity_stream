ActsAsActivityStream.setup do |config|

  # config the social network type
  # :custom friendship need to auth by each other, like facebook
  # :follow follow other users and will get their activities, like twitter
  # config.sns_type = :custom

  # add the extra actor types
  config.actor_types += [:user]

  # add the extra activity types
  # config.activity_types += [:my_activity]

end