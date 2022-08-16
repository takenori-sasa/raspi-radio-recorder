today = Time.zone.today
bow = today.beginning_of_week
eow = today.end_of_week
Raspio::Program::TimeTable.add(bow...eow)
