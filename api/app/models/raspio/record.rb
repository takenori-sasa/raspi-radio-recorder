module Raspio
  class Record < ApplicationRecord
    validates :title, presence: true
    attr_accessor :from, :to, :station_id

    # validate :params

    has_one_attached :audio
    # @see https://radiko.jp/apps/js/playerCommon.js
    # @see https://blog.bluedeer.net/archives/224
    AUTHKEY = 'bcd151073c03b352e1ef2fd66c32209da9ca0afa'.freeze
  end
end
