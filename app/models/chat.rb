class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  has_many :messages, dependent: :destroy
  DEFAULT_TITLE = "Untitled"

  # Retourne un message system avec les détails du trip pour l'IA
  def system_message_content
    <<~MSG
      Tu es une IA spécialisée dans la planification de voyage.
      Trip Details:
      Destination: #{trip.destination}
      Departure: #{trip.departure_city}
      Dates: #{trip.start_date} to #{trip.end_date}
      Travelers: #{trip.traveler_count}
      Budget: #{trip.budget} €
    MSG
  end
end

