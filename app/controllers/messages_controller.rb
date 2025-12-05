class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])

    # 1) Création du message sans fichiers
    @message = Message.new(content: params[:message][:content])
    @message.role = "user"
    @message.chat = @chat

    # 2) Attacher les fichiers uniquement s'il y en a
    if params[:message][:files].present?
      valid_files = params[:message][:files].select { |f| f.is_a?(ActionDispatch::Http::UploadedFile) }

      valid_files.each do |file|
        @message.files.attach(file)
      end
    end

    if @message.save
      # Construire la conversation avec contexte
      conversation = [
        {
          role: "system",
          content: "Tu es une IA spécialisée dans la planification de voyage.
          Tu donnes : météo, conseils, activités, idées de destinations, budgets,
          transports, décalages horaires. Tu te souviens du contexte du chat."
        },
        {
          role: "system",
          content: "Trip Details:\n" +
                  "Destination: #{@chat.trip.destination}\n" +
                  "Departure: #{@chat.trip.departure_city}\n" +
                  "Dates: #{@chat.trip.start_date} to #{@chat.trip.end_date}\n" +
                  "Travelers: #{@chat.trip.traveler_count}\n" +
                  "Budget: #{@chat.trip.budget}"
        }
      ]

      conversation += @chat.messages.order(:created_at).map do |msg|
        { role: msg.role, content: msg.content }
      end

      # # Appel à l'IA
      # ruby_llm_chat = RubyLLM::Chat.new(model: "gpt-4o-mini")  # ou gpt-3.5-turbo selon ton compte
      # prompt = conversation.map { |m| "#{m[:role]}: #{m[:content]}" }.join("\n") #transforme la conv en seul texte

      # Appel à l'IA
      if @message.content.downcase.include?("météo")
        cleaned_content = @message.content.gsub(/[\?\r\n]/, '')
        city = extract_city(cleaned_content)
        weather = fetch_weather(city)

        if weather && weather['main'] && weather['weather']
          temp = weather['main']['temp']
          description = weather['weather'][0]['description']
          assistant_text = "Tu es une IA voyage. Voici la météo actuelle à #{city}: #{temp}°C, #{description}."
        else
          assistant_text = "Désolé, je n'ai pas pu récupérer la météo pour #{city}."
        end
      else
        ruby_llm_chat = RubyLLM::Chat.new(model: "gpt-4o-mini")
        prompt = conversation.map { |m| "#{m[:role]}: #{m[:content]}" }.join("\n")
        response = ruby_llm_chat.ask(prompt)
        assistant_text = response.content # ou response.text selon version
      end

      ia_message = Message.create!(
        role: "assistant",
        chat: @chat,
        content: assistant_text
      )

      # Réponse JSON pour le front
      render json: {
        user_message: @message,
        assistant_message: ia_message
      }, status: :created

    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # message_params NE GÈRE PLUS les fichiers → on le simplifie
  def message_params
    params.require(:message).permit(:content)
  end

  # Récupère la météo depuis OpenWeather
  def fetch_weather(city)
    api_key = ENV["OPENWEATHER_API_KEY"]
    url = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&appid=#{api_key}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end

  # Extraire le nom de la ville depuis le message de l'utilisateur
  def extract_city(text)
    match = text.match(/météo à ([\w\s]+)/i)
    match ? match[1].strip : "Paris"  # par défaut Paris si rien trouvé
  end
end
