FactoryBot.define do
  factory :holding do
    wallet { nil }
    instrument { nil }
    quantity { "9.99" }
    average_price { "9.99" }
  end
end
