require "rails_helper"

RSpec.describe Location, type: :model do
  describe "associations" do
    it { should belong_to(:car) }
    it { should have_one(:trip).through(:car) }
  end

  describe "validations" do
    it { should validate_numericality_of(:direction)
      .is_greater_than_or_equal_to(0).is_less_than_or_equal_to(360)
      .only_integer }
    it { should validate_numericality_of(:latitude)
      .is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90) }
    it { should validate_numericality_of(:longitude)
      .is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180) }
    it { should validate_presence_of(:car) }
    it { should validate_presence_of(:direction) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
  end
end
