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
        number_of_days = (rental.end_date - rental.start_date + 1).to_i
        days_array = (1..number_of_days).to_a
        distance = rental.distance
        price_per_km = rental.car.price_per_km
        total_daily_amount = days_array.map do |day|
          case day
          when 0..1
            rental.car.price_per_day
          when 2..4
            rental.car.price_per_day * 0.9
          when 5..10
          rental.car.price_per_day * 0.7
          else
          rental.car.price_per_day * 0.5
          end
        end
        rental_price = (total_daily_amount.reduce(0, :+) + distance * price_per_km).to_f
        output[:price] = rental_price
        @rentals << output
      end
    end
  end
end
