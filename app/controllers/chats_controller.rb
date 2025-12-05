class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show, :destroy]

  def index
  @chats = current_user.chats.order(created_at: :desc)
  end

  # POST / Chats
  def create
    @trip = Trip.find(params[:trip_id])
    @chat = Chat.new(
      title: Chat::DEFAULT_TITLE,
      user: current_user,
      trip: @trip
    )
    if @chat.save
      redirect_to chat_path(@chat)
    else
       @chats = @trip.chats.where(user: current_user)
       render "trips/show"
    end
  end

  # GET /chat/:id
  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
    @messages = @chat.messages.order(:created_at)
  end

  # DELETE /chats/:id (pas instaurer pour le moment)
  def destroy
    chat_title = @chat.title

    if @chat.destroy
      redirect_to chats_path,
                  notice: "Chat '#{chat_title}' was successfully deleted."
    else
      redirect_to @chat,
                  alert: "Could not delete chat. Please try again."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to chats_path,
                alert: "Chat not found or you don't have permission to delete it."
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:id])
  end

end
