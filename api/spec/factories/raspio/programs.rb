FactoryBot.define do
  factory :raspio_program, class: 'Raspio::Program' do
    raspio_station { nil }
    title { "MyString" }
    description { "MyText" }
    url { "MyString" }
    from { "2022-08-15 19:20:01" }
    to { "2022-08-15 19:20:01" }
  end
end
