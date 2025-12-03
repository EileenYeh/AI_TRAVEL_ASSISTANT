class TripsController < ApplicationController

  before_action :set_trip, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user! # pour model user et current_user ici

  def index
    @trips = current_user.trips
    # au lieu de @trips = Trip.all car on a des users avec devise
  end

  def show
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = current_user.trips.build(trip_params)

    if @trip.save
      redirect_to @trip, notice: "Voyage créé avec succès ✅"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: "Voyage mis à jour ✅"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Voyage supprimé 🗑️"
  end

  private

  def set_trip
    @trip = current_user.trips.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(
      :start_date,
      :end_date,
      :destination,
      :departure_city,
      :traveler_count,
      :budget
    )
end

end
