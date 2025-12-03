class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  has_many :messages, dependent: :destroy
  # nullify ? :id = nil doc active record association
  DEFAULT_TITLE = "Untitled"
end
