class ChatsController < ApplicationController
  before_action :authenticate_user!
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
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to profile_path, notice: "Chat Deleted."
  end

end
