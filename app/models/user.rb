class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :chats, dependent: :destroy
  has_many :trips, dependent: :destroy
  has_many :messages, through: :chats

  # offrir le choix de currency à l'user
  validates :currency, inclusion: { in: ['EUR', 'USD'] }, allow_nil: true

  # la methode pour mettre par défaut currency EUR
  def currency_with_default
    currency.presence || 'EUR'
  end
end
