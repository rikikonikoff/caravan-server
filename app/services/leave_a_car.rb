class LeaveACar
  def initialize(car, user)
    @car = car
    @user = user
    raise ArgumentError, "expected a user" unless @user.class == User
    raise InvalidCarLeave unless @car.class == Car && signup
  end

  def self.perform(car, user)
    new(car, user).perform
  end

  def perform
    if @user == @car.owner
      destroy_car
    else
      @signup.update_attributes!(car: nil)
    end
  end

  def destroy_car
    signups = Signup.where(car: @car)
    signups.each do |signup|
      signup.update_attributes!(car: nil)
    end
    @car.destroy
  end

  def signup
    @signup ||= Signup.find_by(trip: @car.trip, car: @car, user: @user)
  end
end
