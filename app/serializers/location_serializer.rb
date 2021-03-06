class LocationSerializer <  BaseSerializer
  attributes :car_id, :car_name, :direction, :latitude, :longitude

  has_one :car

  def car_name
    object.car.name
  end
end
