class AddColumnSleepDurationToHistories < ActiveRecord::Migration[7.2]
  def change
    add_column :bed_time_histories, :sleep_duration, :integer, default: 0, null: false
    add_index :bed_time_histories, :sleep_duration
  end
end
