module Raspio
  class Station < ApplicationRecord
    validates :id, presence: true
    validates :name, presence: true
    validates :banner, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, if: :banner?
    def banner?
      banner.present?
    end
  end
end
