class AddColumnMetadataToHistories < ActiveRecord::Migration[7.2]
  def change
    add_column :bed_time_histories, :metadata, :json, null: true
  end
end
