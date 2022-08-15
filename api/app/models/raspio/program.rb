class Raspio::Program < ApplicationRecord
  belongs_to :raspio_station, class_name: 'Raspio::Station'
  validates :title, presence: true
  validates :date, presence: true
  validates :from, presence: true, comparison: { less_than: :to }
  validates :homepage, format: /\A#{URI::DEFAULT_PARSER.make_regexp(['http', 'https'])}\z/, allow_blank: true
  validates :to, presence: true, comparison: { greater_than: :from }
  def station
    self.raspio_station
  end
end
