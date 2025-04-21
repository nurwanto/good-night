class CreateUserFollowers < ActiveRecord::Migration[7.2]
  def change
    create_table :user_followers do |t|
      t.references :follower, index: true, null: false, foreign_key: { to_table: :users }
      t.references :followed, index: true, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
