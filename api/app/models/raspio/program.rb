class Raspio::Program < ApplicationRecord
  belongs_to :raspio_station, class_name: 'Raspio::Station'
  validates :title, presence: true
  validates :from, presence: true
  validates :homepage, format: /\A#{URI::DEFAULT_PARSER.make_regexp(['http', 'https'])}\z/, allow_blank: true
  validates :to, presence: true
  validate :from_lt_to
  def station
    self.raspio_station
  end

  private

  def from_lt_to
    # return unless self.from < self.to
    # @todo errorに追加する
  end
end
