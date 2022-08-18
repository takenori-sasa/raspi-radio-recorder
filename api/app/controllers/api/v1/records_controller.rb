require 'tempfile'
module Api
  module V1
    class RecordsController < ApplicationController
      include Raspio
      before_action :set_record, only: [:show, :update, :destroy]

      def index
        records = Raspio::Record.order(updated_at: :desc)
        render json: { status: 'SUCCESS', message: 'Loaded records', data: records }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the record', data: @record }
      end

      def create
        record = Raspio::Record.new(ffmpeg_params)
        Tempfile.open([record.title]) do |tempfile|
          tempfile.binmode
          record.attach_audio(tempfile)
          render json: { status: 'SUCCESS', data: record } if record.save
        end
      rescue StandardError => e
        Rails.logger.error(e.full_message)
        render json: { status: 'ERROR', data: e.full_message }
      end

      def destroy
        @record.destroy
        render json: { status: 'SUCCESS', message: 'Deleted the record', data: @record }
      end

      def update
        if @record.update(record_params)
          render json: { status: 'SUCCESS', message: 'Updated the record', data: @record }
        else
          render json: { status: 'SUCCESS', message: 'Not updated', data: @record.errors }
        end
      end

      private

      def set_record
        @record = Record.find(params[:id])
      end

      def record_params
        params.require(:record).permit(:title)
      end

      def ffmpeg_params
        pparams = params.require(:record)
                        .permit(:station_id, :from,
                                :to)
        # title = "#{params[:record][:station_id]}_#{params[:record][:from]}_#{params[:record][:to]}"
        # pparams.merge(title:).stringify_keys
        pparams.stringify_keys
      end
    end
  end
end
