class Raspio::ProgramJob
  include Sidekiq::Job
  sidekiq_options retry: 5

  def perform(date)
    Raspio::Program::TimeTable.add_time_table(date)
  rescue StandardError => e
    # Do something
  end
end
