require 'uri'
require 'net/http'
require 'base64'
module Raspio
  class Record < ApplicationRecord
    validates :title, presence: true
    attr_accessor :from, :to, :station_id

    has_one_attached :audio
    # @see https://radiko.jp/apps/js/playerCommon.js
    # @see https://blog.bluedeer.net/archives/224
    AUTHKEY = 'bcd151073c03b352e1ef2fd66c32209da9ca0afa'.freeze

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
      system("ffmpeg -headers \"X-Radiko-AuthToken:#{@auth_token}\" -i \"https://radiko.jp/v2/api/ts/playlist.m3u8?station_id=#{station_id}&l=15&ft=#{from}00&to=#{to}00\" -loglevel \"error\" -vn -y -acodec copy #{file.path}")
    end

    def authorize
      # TODO: 例外処理追加
      res1 = Authorizer.authorization1
      return unless res1.is_a?(Net::HTTPSuccess)

      res2 = Authorizer.authorization2(res1)
      return unless res2.is_a?(Net::HTTPSuccess)

      @auth_token = res1['X-Radiko-AuthToken']
    end

    def curl_audio(file)
      system("ffmpeg -headers \"X-Radiko-AuthToken:#{@auth_token}\" -i \"https://radiko.jp/v2/api/ts/playlist.m3u8?station_id=#{station_id}&l=15&ft=#{from}00&to=#{to}00\" -loglevel \"error\" -vn -y -acodec copy #{file.path}")
    end

    def authorize
      # TODO: 例外処理追加
      res1 = Authorizer.authorization1
      return unless res1.is_a?(Net::HTTPSuccess)

      res2 = Authorizer.authorization2(res1)
      return unless res2.is_a?(Net::HTTPSuccess)

      @auth_token = res1['X-Radiko-AuthToken']
    end
    concerning :Authorizer do
      extend ActiveSupport::Concern
      extend self

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
        auth_token = res["X-Radiko-AuthToken"]
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
