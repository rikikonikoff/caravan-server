require "rails_helper"

describe CarPolicy do
  let(:user) { create(:user) }
  let(:car) { create(:car) }

  permissions :create_location? do
    it "grants access if the user is signed up for the car" do
      signup = create(:signup, trip: car.trip, car: car, user: user)
      expect(CarPolicy).to permit(user, car)
    end

    it "denies access if the user is not signed up for the car" do
      expect(CarPolicy).not_to permit(user, car)
    end
  end

  permissions :show? do
    it "grants access if the user is signed up for the trip" do
      signup = create(:signup, trip: car.trip, user: user)
      expect(CarPolicy).to permit(user, car)
    end

    it "denies access if the user is not signed up for the trip" do
      expect(CarPolicy).not_to permit(user, car)
    end
  end

  permissions :update? do
    it "grants access if the user is signed up for the car" do
      signup = create(:signup, trip: car.trip, car: car, user: user)
      expect(CarPolicy).to permit(user, car)
    end

    it "denies access if the user is not signed up for the car" do
      expect(CarPolicy).not_to permit(user, car)
    end
  end
end