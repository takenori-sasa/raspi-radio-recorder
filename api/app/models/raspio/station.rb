module Raspio
  class Station < ApplicationRecord
    validates :id, presence: true
    validates :name, presence: true
    validates :banner, url: { allow_blank: true }
    has_many  :time_tables, dependent: :destroy
  end
end
