class User < ApplicationRecord
  has_many :bed_time_histories
  has_many :followers_relations, foreign_key: :following_id, class_name: "UserFollower"
  has_many :followers, through: :followers_relations, class_name: "User", source: :follower
  has_many :following_relations, foreign_key: :follower_id, class_name: "UserFollower"
  has_many :following, through: :following_relations, class_name: "User", source: :following
end
