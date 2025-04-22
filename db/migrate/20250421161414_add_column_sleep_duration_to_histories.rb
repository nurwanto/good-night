class AddColumnSleepDurationToHistories < ActiveRecord::Migration[7.2]
  def change
    add_column :sleep_histories, :sleep_duration, :integer, default: 0, null: false
    add_index :sleep_histories, :sleep_duration
  end
end
