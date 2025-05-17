class AddSomeIndexesToHistories < ActiveRecord::Migration[7.2]
  def change
    add_index :bed_time_histories, :created_at, name: 'idx_bed_time_histories_created_at'
    add_index :bed_time_histories, [:sleep_duration_in_sec, :id], name: 'idx_bed_time_histories_sleep_duration_in_sec_id'
    add_index :user_followers, [:follower_id, :following_id], name: 'idx_user_followers_follower_id_following_id'
  end
end
