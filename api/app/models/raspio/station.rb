module Raspio
  class Station < ApplicationRecord
    validates :id, presence: true
    validates :name, presence: true
    validates :banner, format: /\A#{URI::DEFAULT_PARSER.make_regexp(['http', 'https'])}\z/, allow_blank: true
    has_many  :raspio_programs, class_name: 'Raspio::Program', foreign_key: :raspio_station_id, dependent: :destroy, inverse_of: :raspio_station
    def programs
      self.raspio_programs
    end
  end
end
