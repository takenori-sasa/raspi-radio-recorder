FactoryBot.define do
  factory :raspio_time_table, class: 'Raspio::TimeTable' do
    station { nil }
    title { "MyString" }
    description { "MyText" }
    homepage { "MyString" }
    from { "2022-08-15 18:13:07" }
    to { "2022-08-15 18:13:07" }
  end
end
