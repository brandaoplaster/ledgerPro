class Wallet < ApplicationRecord
  belongs_to :user

  enum status: { active: 1, inactive: 0 }
end
