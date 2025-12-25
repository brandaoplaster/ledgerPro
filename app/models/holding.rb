class Holding < ApplicationRecord
  belongs_to :wallet
  belongs_to :asset
end
