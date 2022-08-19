require 'faraday'
module Raspio
  class Record < ApplicationRecord
    validates :title, presence: true
    validate :audio_size
    attr_accessor :from, :to, :station_id

    has_one_attached :audio
    # @see https://radiko.jp/apps/js/playerCommon.js
    # @see https://blog.bluedeer.net/archives/224
    AUTH_KEY = 'bcd151073c03b352e1ef2fd66c32209da9ca0afa'.freeze

    # validate :params
    # インスタンスメソッド
    def initialize(params)
      super # superでrecord.from,record.to,record.station_idには代入済んでるけど明示して代入しておく
      station_id = self.station_id
      from = self.from
      to = self.to
      self.title = "#{station_id}_#{from}_#{to}"
    end

    def attach_audio(file)
      authorize
      curl_audio(file)
      self.audio.attach(io: file, filename: "#{title}.aac", content_type: "audio/aac")
    end

    private

    def curl_audio(file)
      system("ffmpeg -headers \"X-Radiko-AuthToken:#{@auth_token}\" -i \"https://radiko.jp/v2/api/ts/playlist.m3u8?station_id=#{station_id}&l=15&ft=#{from}00&to=#{to}00\" -loglevel \"error\" -y -acodec copy #{file.path}")
    end

    def authorize
      # TODO: 例外処理追加
      res1 = Authorizer.authorization1
      return unless res1.success?

      res2 = Authorizer.authorization2(res1.headers)
      return unless res2.success?

      @auth_token = res1.headers['X-Radiko-AuthToken']
    end

    def audio_size
      return unless audio.blob.byte_size == 0.bytes

      audio.purge
      errors.add(:audio, :has_no_record)
    end
    concerning :Authorizer do
      extend ActiveSupport::Concern

      class << self
        def connection
          Faraday.new('https://radiko.jp')
        end

        def authorization1
          connection.get do |request|
            request.url '/v2/api/auth1'
            request.headers["X-Radiko-App"] = "pc_html5"
            request.headers["X-Radiko-App-Version"] = "0.0.1"
            request.headers["X-Radiko-User"] = "dummy_user"
            request.headers["X-Radiko-Device"] = "pc"
          end
        end

        def authorization2(header1)
          auth_token = header1["X-Radiko-AuthToken"]
          key_length = header1['X-Radiko-KeyLength'].to_i
          key_offset = header1['X-Radiko-KeyOffset'].to_i
          connection.get do |request|
            request.url '/v2/api/auth2'
            request.headers['X-Radiko-AuthToken'] = auth_token
            request.headers['X-Radiko-PartialKey'] = partial_key(AUTH_KEY, key_length, key_offset)
            request.headers["X-Radiko-User"] = "dummy_user"
            request.headers["X-Radiko-Device"] = "pc"
          end
        end

        def partial_key(key, length, offset)
          Base64.encode64(key.slice(offset, length))
        end
      end
    end
  end
end
