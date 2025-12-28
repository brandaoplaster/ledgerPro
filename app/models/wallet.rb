class Wallet < ApplicationRecord
  belongs_to :user
  has_many :holdings

  enum :status, { active: 1, inactive: 0 }
  validates :name, presence: true
end
