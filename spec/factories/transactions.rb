FactoryBot.define do
  factory :transaction do
    wallet { nil }
    instrument { nil }
    kind { 1 }
    quantity { "9.99" }
    price { "9.99" }
    occurred_at { "2025-12-25 00:14:19" }
  end
end
