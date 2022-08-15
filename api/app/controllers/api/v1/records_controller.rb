require 'uri'
require 'net/http'
require 'base64'
require 'tempfile'
module Api
  module V1
    class RecordsController < ApplicationController
      include Raspio
      before_action :authorization, only: [:create]
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
        Tempfile.open(["#{record.title}", ".aac"]) do |file|
          file.binmode
          result = download_audio(file, record)
          render json: { status: 'ERROR', data: 'download failed.' } and return unless result

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
        title = "#{params[:record][:station_id]}_#{params[:record][:from]}_#{params[:record][:to]}"
        params.require(:record).permit(:station_id, :from,
                                       :to).merge(title:)
      end

      def authorization
        res1 = authorization1
        render json: { status: 'ERROR', data: 'authorization1 failed.' } and return unless res1.is_a?(Net::HTTPSuccess)

        res2 = authorization2(res1)
        render json: { status: 'ERROR', data: 'authorization2 failed.' } and return unless res2.is_a?(Net::HTTPSuccess)

        @auth_token = res1['X-Radiko-AuthToken']
      end

      def download_audio(file, record)
        station_id = record.station_id
        from = record.from
        to = record.to
        system("ffmpeg -headers \"X-Radiko-AuthToken:#{@auth_token}\" -i \"https://radiko.jp/v2/api/ts/playlist.m3u8?station_id=#{station_id}&l=15&ft=#{from}00&to=#{to}00\" -loglevel \"error\" -vn -y -acodec copy #{file.path}")
      end

      def authorization1
        uri = URI.parse('https://radiko.jp/v2/api/auth1')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"

        autho1_headers = { 'X-Radiko-App': 'pc_html5',
                           'X-Radiko-App-Version': '0.0.1',
                           'X-Radiko-User': 'dummy_user',
                           'X-Radiko-Device': 'pc' }
        http.get(uri.path, autho1_headers)
      end

      def authorization2(res)
        auth_token = res['X-Radiko-AuthToken']
        key_length = res['X-Radiko-KeyLength'].to_i
        key_offset = res['X-Radiko-KeyOffset'].to_i
        autho2_headers = { 'X-Radiko-AuthToken': auth_token,
                           'X-Radiko-PartialKey': partial_key(Record::AUTHKEY, key_length, key_offset),
                           'X-Radiko-User': 'dummy_user',
                           'X-Radiko-Device': 'pc' }
        uri = URI.parse('https://radiko.jp/v2/api/auth2')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.get(uri.path, autho2_headers)
      end

      def partial_key(key, length, offset)
        Base64.encode64(key.slice(offset, length))
      end
    end
  end
end