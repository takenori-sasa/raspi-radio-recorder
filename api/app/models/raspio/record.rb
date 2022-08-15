module Raspio
  class Record < ApplicationRecord
    validates :title, presence: true
    has_one_attached :audio
  end
end
