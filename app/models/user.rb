class User < ApplicationRecord
  has_many :bed_time_histories
  has_many :followers_relations, foreign_key: :followed_id, class_name: 'UserFollower'
  has_many :followers, through: :followers_relations, class_name: 'User', source: :follower
  has_many :followed_relations, foreign_key: :follower_id, class_name: 'UserFollower'
  has_many :followed, through: :followed_relations, class_name: 'User', source: :followed
end
