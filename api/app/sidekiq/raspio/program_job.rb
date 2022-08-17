class Raspio::ProgramJob
  include Sidekiq::Job
  sidekiq_options retry: 5
  sidekiq_retries_exhausted do |msg, ex|
    # ExceptionNotifier.call(msg, ex)
  end

  def perform(dates)
    Raspio::Program.add_datestr(dates)
  end
end
