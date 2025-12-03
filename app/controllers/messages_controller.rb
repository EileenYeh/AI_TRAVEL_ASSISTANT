class MessagesController < ApplicationController

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.create!(
      role: `user`,
      content: params[:content]
    )

    redirect_to chat_ai_chemin(@chat)
  end

  def ai_response
    @chat = Chat.find(params[:id])
    @chat.messages.create!(
      role: `assistant`,
      content: ai_text
    )

    redirect_to chat_chemin(@chat)
  end

end
