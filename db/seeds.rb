# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# 1. Clean the database 🗑️
puts "Cleaning database..."
User.destroy_all
Trip.destroy_all

# 2. Users
user1 = User.create!(
  email: 'orion@example.com',
  password: 'password123',
  password_confirmation: 'password123')
user2 = User.create!(
  email: 'hanying@example.com',
  password: 'password123',
  password_confirmation: 'password123')
user3 = User.create!(
email: 'lea@example.com',
password: 'password123',
password_confirmation: 'password123')

#3. Users reliés à Trips
user1.trips.create!(
  destination: 'Tokyo',
  departure_city: 'Paris',
  start_date: Date.today + 30,
  end_date: Date.today + 40,
  traveler_count: 2,
  budget: 2000
)
user2.trips.create!(
  destination: 'New York',
  departure_city: 'Lyon',
  start_date: Date.today + 60,
  end_date: Date.today + 68,
  traveler_count: 1,
  budget: 1200
)
user3.trips.create!(
  destination: 'Barcelone',
  departure_city: 'Marseille',
  start_date: Date.today + 10,
  end_date: Date.today + 15,
  traveler_count: 4,
  budget: 1500
)
