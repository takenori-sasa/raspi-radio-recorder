require 'faraday'
module Raspio
  class Record < ApplicationRecord
    validates :title, presence: true
    validate :audio_size, :audio?
    attribute :from, :string
    attribute :to, :string
    attribute :station_id, :string

    has_one_attached :audio

    # validate :params
    # インスタンスメソッド
    def initialize(params)
      super # superでrecord.from,record.to,record.station_idには代入済んでるけど明示して代入しておく
      binding.pry
      self.title = "#{self.station_id}_#{format_time(self.from)}_#{format_time(self.to)}"
    end

    def attach_audio(file)
      authorize
      curl_audio(file)
      self.audio.attach(io: file, filename: "#{title}.aac", content_type: "audio/aac")
    end

    private

    def curl_audio(file)
      # TODO: 400 Bad Req エラー追加
      system("ffmpeg -headers \"X-Radiko-AuthToken:#{@auth_token}\" -i \"https://radiko.jp/v2/api/ts/playlist.m3u8?station_id=#{station_id}&l=15&ft=#{format_time(from)}&to=#{format_time(to)}\" -loglevel \"error\" -y -acodec copy #{file.path}")
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

    def audio?
      audio.attached?
    end

    def format_time(time)
      Time.parse(time).strftime('%Y%m%d%H%M') + '00'
    end

    module Authorizer
      extend ActiveSupport::Concern
      # @see https://blog.bluedeer.net/archives/224
      # https://radiko.jp/apps/js/playerCommon.js内に書かれてる
      AUTH_KEY = 'bcd151073c03b352e1ef2fd66c32209da9ca0afa'.freeze
      private_constant :AUTH_KEY
      class << self
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

        private

        def connection
          Faraday.new('https://radiko.jp')
        end

        def partial_key(key, length, offset)
          Base64.encode64(key.slice(offset, length))
        end
      end
    end
  end
end
