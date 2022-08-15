class Raspio::Program < ApplicationRecord
  belongs_to :raspio_station
  validates :title, presence: true
  validates :from, presence: true
  validates :homepage, url: { allow_nil: true }
  validates :to, presence: true
end
