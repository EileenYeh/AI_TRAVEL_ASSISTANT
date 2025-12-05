require 'open-uri'
require 'net/http'

class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])

    # Création du message
    @message = Message.new(message_params)
    @message.role = "user"
    @message.chat = @chat

    # Attacher les fichiers s'il y en a
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
          content: "Tu es une IA spécialisée dans la planification de voyage. Tu donnes : météo, conseils, activités, idées de destinations, budgets, transports, décalages horaires. Tu te souviens du contexte du chat."
        }
      ]

      # Ajouter les détails du voyage si disponibles
      if @chat.trip.present?
        conversation << {
          role: "system",
          content: "Trip Details:\n" +
                  "Destination: #{@chat.trip.destination}\n" +
                  "Departure: #{@chat.trip.departure_city}\n" +
                  "Dates: #{@chat.trip.start_date} to #{@chat.trip.end_date}\n" +
                  "Travelers: #{@chat.trip.traveler_count}\n" +
                  "Budget: #{@chat.trip.budget}"
        }
      end

      # Ajouter l'historique des messages
      conversation += @chat.messages.order(:created_at).map do |msg|
        { role: msg.role, content: msg.content }
      end

      # Vérifier si c'est une requête météo
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
        # Appel à l'IA pour les autres requêtes
        begin
          ruby_llm_chat = RubyLLM.chat
          prompt = conversation.map { |m| "#{m[:role]}: #{m[:content]}" }.join("\n")
          response = ruby_llm_chat.ask(prompt)
          assistant_text = response.content
        rescue => e
          Rails.logger.error "Erreur lors de l'appel à l'IA: #{e.message}"
          assistant_text = "Désolé, une erreur est survenue lors du traitement de votre requête."
        end
      end

      # Créer la réponse de l'assistant
      @assistant_message = Message.create!(
        role: "assistant",
        chat: @chat,
        content: assistant_text
      )

      # Générer le titre à partir du premier message
      @chat.generate_title_from_first_message

      # Répondre selon le format demandé
      respond_to do |format|
        format.html { redirect_to chat_path(@chat) }
        format.json {
          render json: {
            user_message: @message,
            assistant_message: @assistant_message
          }, status: :created
        }
      end
    else
      respond_to do |format|
        format.html { render "chats/show", status: :unprocessable_entity }
        format.json { render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def fetch_weather(city)
    api_key = ENV["OPENWEATHER_API_KEY"]

    # Gestion des erreurs pour l'appel API
    begin
      url = URI.parse("https://api.openweathermap.org/data/2.5/weather?q=#{URI.encode_www_form_component(city)}&units=metric&appid=#{api_key}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url.request_uri)
      response = http.request(request)

      return JSON.parse(response.body)
    rescue => e
      Rails.logger.error "Erreur lors de la récupération de la météo: #{e.message}"
      return nil
    end
  end

  def extract_city(text)
    match = text.match(/météo à ([\w\s]+)/i)
    match ? match[1].strip : "Paris"
  end
end
