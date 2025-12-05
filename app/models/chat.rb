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
  
  TITLE_PROMPT = <<~PROMPT
    Generate a short, descriptive, 3-to-6-word title that summarizes the user question for a chat conversation.
  PROMPT
  def generate_title_from_first_message
    return unless title == DEFAULT_TITLE

    first_user_message = messages.where(role: "user").order(:created_at).first
    return if first_user_message.nil?

    response = RubyLLM.chat.with_instructions(TITLE_PROMPT).ask(first_user_message.content)
    update(title: response.content)
  end
end
