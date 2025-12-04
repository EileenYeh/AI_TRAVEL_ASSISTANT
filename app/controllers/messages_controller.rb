class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.role = "user"
    @message.chat = @chat

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.ask(@message.content)

      Message.create!(
        role: "assistant",
        chat: @chat,
        content: response.content
      )
      # juste cette ligne qui change le titre:
      @chat.generate_title_from_first_message

      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
