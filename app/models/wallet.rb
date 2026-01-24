class Wallet < ApplicationRecord
  belongs_to :user
  has_many :holdings
  has_many :transactions
  has_one :strategy

  enum :status, { active: 1, inactive: 0 }
  validates :name, presence: true
end
