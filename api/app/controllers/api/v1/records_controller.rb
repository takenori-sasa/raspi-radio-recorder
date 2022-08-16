require 'tempfile'
require 'pry'
module Api
  module V1
    class RecordsController < ApplicationController
      include Raspio
      before_action :set_record, only: [:show, :update, :destroy]

      def index
        records = Record.order(created_at: :desc)
        render json: { status: 'SUCCESS', message: 'Loaded records', data: records }
      end

      def show
        render json: { status: 'SUCCESS', message: 'Loaded the record', data: @record }
      end

      def create
        record = Raspio::Record.new(ffmpeg_params)
        record.authorize
        Tempfile.open([record.title, ".aac"]) do |file|
          file.binmode
          result = record.append(file)
          render json: { status: 'ERROR', data: 'download failed.' } unless result

          record.audio.attach(io: file, filename: "#{record.title}.aac", content_type: "audio/aac")
          if record.save
            render json: { status: 'SUCCESS', data: record }
          else
            render json: { status: 'ERROR', data: record.errors }
          end
        end
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
        title = "#{params[:record][:station_id]}_#{params[:record][:from]}_#{params[:record][:to]}"
        pparams.merge(title:)
      end
    end
  end
end
