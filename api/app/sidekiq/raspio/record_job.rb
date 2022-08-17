require 'tempfile'
class Raspio::RecordJob
  include Sidekiq::Job
  sidekiq_options retry: 5

  sidekiq_retries_exhausted do |msg, exception|
    Rails.logger.error(msg)
    Rails.logger.error(exception)
    # ExceptionNotifier.call(msg, ex)
  end

  def perform(params)
    # params
    # from String %Y%m%d%H%M 202208140330
    # to String %Y%m%d%H%M 202208140345
    # station_id String MBS
    # title String
    record = Raspio::Record.new(params)
    record.authorize
    Tempfile.open([record.title, ".aac"]) do |tmpfile|
      record.attach(tmpfile)
      record.save
    end
  end
end
# param = {
#   station_id: 'MBS',
#   from: '202208140330',
#   to: '202208140345',
#   title: 'MBS_202208140330'
# }
# Raspio::RecordJob.perform_async(param.stringify_keys)
