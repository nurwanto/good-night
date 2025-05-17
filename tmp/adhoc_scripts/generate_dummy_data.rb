require 'active_record'
require 'faker'
require 'dotenv/load'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: ENV["DB_HOST"],
  username: ENV["DB_USERNAME"],
  password: ENV["DB_PASSWORD"],
  database: ENV["DB_NAME"],
)

# Define models
class User < ActiveRecord::Base
  has_many :bed_time_histories
  has_many :followers, class_name: 'UserFollower', foreign_key: 'following_id'
  has_many :followings, class_name: 'UserFollower', foreign_key: 'follower_id'
end

class BedTimeHistory < ActiveRecord::Base
  belongs_to :user
end

class UserFollower < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: 'User'
end

# Generate dummy data
def generate_dummy_data(data_size = 1, batch_size = 10_000)
  start_time = Time.now # Capture the start time
  puts "Starting data generation at #{start_time}..."

  # Generate users
  puts "Generating users..."
  data_size.times.each_slice(batch_size) do |batch|
    users = batch.map do
      { name: Faker::Name.name, created_at: Time.now, updated_at: Time.now }
    end
    User.insert_all(users)
  end

  # Generate bed_time_histories
  puts "Generating bed_time_histories..."
  user_ids = User.pluck(:id, :name) # Fetch both user IDs and names
  user_ids.each_slice(batch_size) do |batch|
    bed_time_histories = batch.map do |user_id, user_name|
      bed_time = Faker::Time.backward(days: 30)
      wake_up_time = bed_time + rand(6..10).hours
      {
        user_id: user_id,
        bed_time: bed_time,
        wake_up_time: wake_up_time,
        sleep_duration_in_sec: (wake_up_time - bed_time).to_i,
        metadata: { username: user_name }.to_json, # Updated metadata
        created_at: Time.now,
        updated_at: Time.now
      }
    end
    BedTimeHistory.insert_all(bed_time_histories)
  end

  # Generate user_followers
  puts "Generating user_followers..."
  user_ids = User.pluck(:id) # Fetch only user IDs
  user_ids.shuffle.each_slice(batch_size) do |batch|
    user_followers = batch.map do
      follower_id = user_ids.sample
      following_id = user_ids.sample

      # Ensure follower_id and following_id are not nil and not the same
      next if follower_id.nil? || following_id.nil? || follower_id == following_id

      {
        follower_id: follower_id,
        following_id: following_id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end.compact # Remove nil entries caused by `next`
    UserFollower.insert_all(user_followers) if user_followers.any? # Insert only if there are valid records
  end

  end_time = Time.now # Capture the end time
  puts "Data generation completed at #{end_time}!"

  # Calculate and print the duration
  duration = end_time - start_time
  formatted_duration = Time.at(duration).utc.strftime("%H:%M:%S")
  puts "Total duration: #{formatted_duration}"
end

# Run the script, will need about 12 minutes to generate 1 million users and all data dependencies
generate_dummy_data(1_000_000, 10_000)
