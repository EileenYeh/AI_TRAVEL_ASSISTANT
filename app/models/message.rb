class Message < ApplicationRecord
  belongs_to :chat
  # , optional: true

  validates :content, presence: true
  # :length { }
  validates :role, inclusion: { in: ["user", "assistant"] }
end
