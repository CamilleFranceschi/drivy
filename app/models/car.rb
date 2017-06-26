class Car < ApplicationRecord
  has_many :rentals, dependent: :destroy
  validates :price_per_day, presence: true
  validates :price_per_km, presence: true
end
