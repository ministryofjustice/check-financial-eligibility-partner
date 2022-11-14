FactoryBot.define do
  factory :partner do
    date_of_birth { Faker::Date.between(from: 18.years.ago, to: 70.years.ago) }
  end
end
