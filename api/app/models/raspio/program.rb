class Raspio::Program < ApplicationRecord
  belongs_to :raspio_station, class_name: 'Raspio::Station'
  validates :title, presence: true
  validates :from, presence: true
  validates :homepage, url: { allow_nil: true }
  validates :to, presence: true
end
