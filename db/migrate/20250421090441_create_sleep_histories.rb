class CreateSleepHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :sleep_histories do |t|
      t.datetime :bed_time
      t.datetime :wake_up_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
