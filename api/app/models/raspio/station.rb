module Raspio
  class Station < ApplicationRecord
    validates :id, presence: true
    validates :name, presence: true
    validates :banner, url: { allow_blank: true }
    has_many  :programs, class_name: 'Raspio::Program', dependent: :destroy
  end
end
