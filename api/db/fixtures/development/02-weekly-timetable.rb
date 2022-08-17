today = Time.zone.today
bow = today - 7
eow = today + 7
(bow...eow).to_a.each do |date|
  Raspio::Program.add(date)
end
