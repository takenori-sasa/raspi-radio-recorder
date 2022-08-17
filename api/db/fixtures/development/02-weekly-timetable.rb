today = Time.zone.today
bow = today.beginning_of_week
eow = today.end_of_week
Raspio::Program.add((bow...eow).to_a)
