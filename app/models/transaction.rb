class Transaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :instrument

  enum :kind, { buy: 1, sell: 0 }
end
