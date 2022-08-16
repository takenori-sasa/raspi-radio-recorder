class Raspio::ProgramJob
  include Sidekiq::Job
  sidekiq_options retry: 5
  sidekiq_retries_exhausted do |msg, ex|
    # ExceptionNotifier.call(msg, ex)
  end

  def perform(date)
    Raspio::Program::TimeTable.add_time_table(date)
  rescue StandardError => e
    # Do something
  end
end
