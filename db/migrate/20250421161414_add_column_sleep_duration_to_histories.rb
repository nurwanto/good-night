class AddColumnSleepDurationToHistories < ActiveRecord::Migration[7.2]
  def change
    add_column :bed_time_histories, :sleep_duration_in_sec, :integer, default: 0, null: false
    add_index :bed_time_histories, :sleep_duration_in_sec
  end
end
