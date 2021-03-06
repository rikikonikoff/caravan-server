require "rails_helper"

describe "LeaveCar Request" do
  describe "PATCH /cars/:car_id/leave" do
    context "authenticated user" do
      let!(:current_user) { create(:user) }
      let!(:google_identity) { create(:google_identity, user: current_user) }

      context "user is signed up for a car in a trip" do
        it "removes the user from the car & returns 204 No Content" do
          car = create(:car, max_seats: 2)
          trip = car.trip
          signup = create(:signup, trip: trip, car: car, user: current_user)
          signup_2 = create(:signup, trip: trip, car: car, user: car.owner)

          expect(car.owner).not_to eq(current_user)
          expect(car.users).to include(current_user)
          expect(car.users.count).to eq(2)

          patch(
            api_v1_car_leave_url(car),
            headers: authorization_headers(current_user)
          )

          expect(response).to have_http_status :no_content

          car.reload
          expect(car).to be
          expect(car.users).to_not include(current_user)
          signup.reload
          expect(signup).to be
          expect(signup.car_id).to eq(nil)
          signup_2.reload
          expect(signup_2).to be
          expect(signup_2.car).to eq(car)
        end
      end

      context "user is the car's owner, and is signed up for the trip & car" do
        it "deletes the car and updates all relevant signups" do
          car = create(:car, owner: current_user, max_seats: 3)
          trip = car.trip
          signup = create(:signup, trip: trip, car: car, user: current_user)
          signup_2 = create(:signup, trip: trip, car: car)

          expect(car.owner).to eq(current_user)
          expect(car.users).to include(current_user)
          expect(car.users.count).to eq(2)

          patch(
            api_v1_car_leave_url(car),
            headers: authorization_headers(current_user)
          )

          expect(response).to have_http_status :no_content
          expect{ Car.find(car.id) }.to raise_error(ActiveRecord::RecordNotFound)

          signup.reload
          expect(signup.car).not_to be
          signup_2.reload
          expect(signup_2.car).not_to be
        end
      end

      context "invalid signup" do
        context "user is not signed up for the trip or the car" do
          it "returns 403 Forbidden" do
            car = create(:car)

            patch(
            api_v1_car_leave_url(car),
            headers: authorization_headers(current_user)
            )

            expect_user_forbidden_response
          end
        end

        context "user is signed up for the trip, but not the car" do
          it "returns 403 Forbidden" do
            trip = create(:trip)
            car = create(:car, trip: trip)
            signup = create(:signup, trip: trip, user: current_user)

            patch(
              api_v1_car_leave_url(car),
              headers: authorization_headers(current_user)
            )

            expect_user_forbidden_response
          end
        end

        context "user tries to sign up for the car, but not the trip" do
          it "returns 403 Forbidden" do
            trip = create(:trip)
            car = create(:car, trip: trip)
            expect { signup = create(:signup, car: car, user: current_user) }
              .to raise_error(ActiveRecord::RecordInvalid,
              "Validation failed: Car must belong to the Signup's trip")

            patch(
              api_v1_car_leave_url(car),
              headers: authorization_headers(current_user)
            )

            expect_user_forbidden_response
          end
        end
      end

      context "invalid car_id" do
        it "returns 404 Not Found" do
          patch(
            api_v1_car_leave_url("gobbledegook"),
            headers: authorization_headers(current_user)
          )

          expect(response).to have_http_status :not_found
          expect(errors).to eq("Couldn't find Car with 'id'=gobbledegook")
        end
      end

      context "user tries to sign up for the car, but it exists on a different trip" do
        it "returns 403 Forbidden" do
          car = create(:car)
          expect { signup = create(:signup, car: car, user: current_user) }
            .to raise_error(ActiveRecord::RecordInvalid,
            "Validation failed: Car must belong to the Signup's trip")

          patch(
            api_v1_car_leave_url(car),
            headers: authorization_headers(current_user)
          )

          expect_user_forbidden_response
        end
      end
    end

    context "unauthenticated user" do
      context "no authorization header" do
        it "returns 401 Unauthorized" do
          car = create(:car)
          signup = create(:signup, trip: car.trip, car: car)

          patch(
            api_v1_car_leave_url(car),
            headers: accept_headers
          )

          expect(response).to have_http_status :unauthorized
        end
      end

      context "invalid auth token" do
        it "returns 401 Unauthorized" do
          car = create(:car)
          signup = create(:signup, trip: car.trip, car: car)

          patch(
            api_v1_car_leave_url(car),
            headers: invalid_authorization_headers
          )

          expect(response).to have_http_status :unauthorized
        end
      end
    end
  end
end
