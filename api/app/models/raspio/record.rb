module Raspio
  class Record < ApplicationRecord
    has_one_attached :audio
  end
end
