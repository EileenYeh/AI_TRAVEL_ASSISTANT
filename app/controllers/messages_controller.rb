def create
  @chat = Chat.find(params[:chat_id])
  @message = Message.new(message_params)
  @message.role = "user"
  @message.chat = @chat

  if @message.save   # Sauvegarde du message utilisateur

    # Construire la conversation avec contexte
    conversation = [
      {
        role: "system",
        content: "Tu es une IA spécialisée dans la planification de voyage.
        Tu donnes : météo, conseils, activités, idées de destinations, budgets,
        transports, décalages horaires. Tu te souviens du contexte du chat."
      }
    ]

    conversation += @chat.messages.order(:created_at).map do |msg|
      { role: msg.role, content: msg.content }
    end

    # Appel à l'IA
    ruby_llm_chat = RubyLLM.chat
    response = ruby_llm_chat.chat(messages: conversation)

    # Création du message de l’IA
    Message.create!(
      role: "assistant",
      chat: @chat,
      content: response.content
    )

    redirect_to chat_path(@chat)

  else
    render "chats/show", status: :unprocessable_entity
  end
end
