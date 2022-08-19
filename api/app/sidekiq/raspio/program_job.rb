class Raspio::ProgramJob
  include Sidekiq::Job
  sidekiq_options retry: 5
  sidekiq_options queue: 'low'
  sidekiq_retries_exhausted do |msg, exception|
    Rails.logger.error(msg)
    Rails.logger.error(exception)
    # ExceptionNotifier.call(msg, ex)
  end

  def perform(date_str)
    # params
    # dates_str [string]
    Raspio::Program.add(date_str)
  end
end
# Test code
# today = Time.zone.today
# dates = (today - 3...today + 3).to_a
# dates.each do |date|
#   date_str = date.strftime("%Y%m%d")
#   p date_str
#   Raspio::ProgramJob.perform_async(date_str)
# end
