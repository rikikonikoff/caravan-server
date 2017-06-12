class Location < ApplicationRecord
  belongs_to :car

  validates :car, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
