class Wallet < ApplicationRecord
  belongs_to :user
  has_many :holdings
  has_many :transactions

  enum :status, { active: 1, inactive: 0 }
  validates :name, presence: true
end
