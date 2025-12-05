class Message < ApplicationRecord
  MAX_USER_MESSAGES = 20 # Augmenter pour les conversations de voyage
  MAX_CONTENT_LENGTH = 2000 # Les questions de voyage peuvent être longues
  belongs_to :chat
  # , optional: true

  has_many_attached :files #c est lié à Active Storage

  validates :content, presence: true, unless: -> { files.attached? }
  # :length { }
  validates :role, inclusion: { in: ["user", "assistant"] }

  validates :content, length: { minimum: 2, maximum: MAX_CONTENT_LENGTH }, if: -> { role == "user" }

  # Validation pour limiter le nombre de messages (optionnel)
  validate :user_message_limit, if: -> { role == "user" && new_record? }

  private

  def user_message_limit
    if chat.messages.where(role: "user").count >= MAX_USER_MESSAGES
      errors.add(:base, "You've reached the maximum of #{MAX_USER_MESSAGES} messages for this chat.")
    end
  end
end
