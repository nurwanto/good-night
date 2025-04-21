# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

UserFollower.destroy_all
BedTimeHistory.destroy_all
User.destroy_all

user_name = %w[Alice Bob Charlie].freeze

user_name.each do |name|
  # create dummy user
  user = User.create!(name: name)

  # create dummy bed time history
  4.times do |idx|
    min_date = Time.now - (idx + 1).days
    max_date = Time.now - idx.days
    bed_time = rand(min_date..max_date)
    wake_up_time = rand(bed_time..max_date)

    BedTimeHistory.create!(user_id: user.id, bed_time: bed_time, wake_up_time: wake_up_time)
  end
end

# create dummy followers
alice_id = User.find_by(name: 'Alice').id
bob_id = User.find_by(name: 'Bob').id
charlie_id = User.find_by(name: 'Charlie').id

UserFollower.create!(follower_id: alice_id, followed_id: bob_id)
UserFollower.create!(follower_id: alice_id, followed_id: charlie_id)
UserFollower.create!(follower_id: bob_id, followed_id: charlie_id)
