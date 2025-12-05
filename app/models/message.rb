class Message < ApplicationRecord
  belongs_to :chat
  # , optional: true

  has_many_attached :files #c est lié à Active Storage

  validates :content, presence: true, unless: -> { files.attached? }
  # :length { }
  validates :role, inclusion: { in: ["user", "assistant"] }
end
