class Raspio::RecordJob
  include Sidekiq::Job
  sidekiq_options retry: 5

  sidekiq_retries_exhausted do |msg, ex|
    # ExceptionNotifier.call(msg, ex)
  end

  def perform(_params)
    # TODO: strong params 通す?
    # Recordにcreate作ってcontrollerの移送する
    # Api::V1::RecordsController.create
  end
end