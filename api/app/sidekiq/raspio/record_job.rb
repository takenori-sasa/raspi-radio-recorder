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
    Tempfile.open([record.title, '.aac']) do |file|
      file.binmode
      record.attach_audio(file)
      record.save
    end
  end
end
# p = {
#   station_id: 'MBS',
#   from: '202208140330',
#   to: '202208140345',
#   title: 'MBS_202208140330'
# }
# Raspio::RecordJob.perform_async(p.stringify_keys)
