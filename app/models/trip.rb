class Trip < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy

  validates :start_date, :end_date, :destination_country, :departure_city,
            :travelers_count, :budget, presence: true

  validates :travelers_count, :budget, numericality: { greater_than: 0 }

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    if end_date < start_date
      errors.add(:end_date, "doit être après la date de départ")
    end
  end

end
