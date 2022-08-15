class Raspio::TimeTable < ApplicationRecord
  belongs_to :station
  validates :title, presence: true
  validates :from, presence: true
  validates :homepage, url: { allow_blank: true }
  validates :to, presence: true
end
