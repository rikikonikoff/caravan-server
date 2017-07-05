require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "associations" do
    it { should belong_to(:creator) }
    it { should belong_to(:invite_code) }
    it { should have_many(:cars) }
    it { should have_many(:locations).through(:cars) }
    it { should have_many(:signups) }
    it { should have_many(:users).through(:signups) }
  end

  describe "validations" do
    it { should validate_presence_of(:creator) }
    it { should validate_presence_of(:departing_on) }
    it { should validate_presence_of(:destination_address) }
    it { should validate_presence_of(:destination_latitude) }
    it { should validate_presence_of(:destination_longitude) }
    it { should validate_presence_of(:invite_code_id) }
    it { should validate_presence_of(:name) }
  end

  describe "last_locations" do
    it "returns the most recent locations for each car in the trip" do
      trip = create(:trip)
      car1 = create(:car, trip: trip)
      car2 = create(:car, trip: trip)
      create_list(:location, 2, car: car1)
      create_list(:location, 2, car: car2)
      car1_last_location = create(:location, car: car1, latitude: 1.00, longitude: 2.00)
      car2_last_location = create(:location, car: car2, latitude: 3.00, longitude: 4.00)

      expect(trip.last_locations[0].latitude).to eq car1_last_location.latitude
      expect(trip.last_locations[0].longitude).to eq car1_last_location.longitude
      expect(trip.last_locations[1].latitude).to eq car2_last_location.latitude
      expect(trip.last_locations[1].longitude).to eq car2_last_location.longitude
    end
  end

  describe "valid_code?" do
    context "valid code" do
      it "returns true" do
        invite_code = create(:invite_code)
        trip = create(:trip, invite_code: invite_code)

        expect(trip.valid_code?(invite_code.code)).to be true
      end
    end

    context "invalid code" do
      it "returns false" do
        invite_code = create(:invite_code)
        trip = create(:trip, invite_code: invite_code)

        expect(trip.valid_code?("abcdef")).to be false
      end
    end
  end
end
