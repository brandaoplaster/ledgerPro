FactoryBot.define do
  factory :wallet do
    name { Faker::Finance.account_name }
    status { Wallet.statuses.keys.sample.to_sym }
    association user
  end
end
