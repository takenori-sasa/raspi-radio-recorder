class Raspio::ProgramJob
  include Sidekiq::Job
  sidekiq_options retry: 5
  sidekiq_options queue: 'low'
  sidekiq_retries_exhausted do |msg, _ex|
    Rails.logger.error(msg)
    Rails.logger.error(exception)
    # ExceptionNotifier.call(msg, ex)
  end

  def perform(dates_str)
    # params
    # dates_str [string]
    dates_str.each do |date_str|
      Raspio::Program.add(date_str)
    end
  end
end
# Test code
# today = Time.zone.today
# dates = (today - 3...today + 3).to_a
# dates.map! do |date|
#   date.strftime("%Y%m%d")
# end
# Raspio::ProgramJob.perform_async(dates)
