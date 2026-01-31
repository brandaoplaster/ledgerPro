class Instrument < ApplicationRecord
  has_many :holdings, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :wallets, through: :holdings
  has_many :instrument_metrics, dependent: :destroy
end
