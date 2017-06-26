class Api::V1::RentalsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: :index
  def index
    cars = policy_scope(Car)
    @rentals = []
    cars.each do |car|
      car.rentals.each do |rental|
        output = {}
        output[:id] = rental.id
        car_hash = car.attributes
        number_of_days = rental.end_date - rental.start_date + 1
        distance = rental.distance
        price_per_km = rental.car.price_per_km
        price_per_day =  rental.car.price_per_day
        rental_price = (number_of_days * price_per_day + distance * price_per_km).to_f
        output[:price] = rental_price
        @rentals << output
      end
    end
  end
end
