class AddCompositeIndexToUserFollower < ActiveRecord::Migration[7.2]
  def change
    add_index :user_followers, %i[following_id follower_id], unique: true
  end
end
