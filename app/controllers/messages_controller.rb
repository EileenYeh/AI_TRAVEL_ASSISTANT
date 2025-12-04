class MessagesController < ApplicationController
  def create          #creation message user
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.role = "user"
    @message.chat = @chat

    if @message.save    #message du user enregistrer pour que l IA réponde
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.ask(@message.content)

      Message.create!(    #créer message de l IA
        role: "assistant",
        chat: @chat,
        content: response.content
      )

      redirect_to chat_path(@chat)  #redirige vers la page du tchat
    else
      render "chats/show", status: :unprocessable_entity  #si jamais y a une erreur ca devrait afficher un message
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, files: []) #pour mettre plusieurs fichiers)
  end
end
