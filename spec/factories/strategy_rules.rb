FactoryBot.define do
  factory :strategy_rule do
    strategy { nil }
    asset_kind { "MyString" }
    max_percenage { "9.99" }
  end
end
