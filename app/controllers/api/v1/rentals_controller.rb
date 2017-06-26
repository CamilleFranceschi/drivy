class Api::V1::RentalsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: :index
  def index
    cars = policy_scope(Car)
    @rentals = []
    @commissions = []
    cars.each do |car|
      car.rentals.each do |rental|
        output = {}
        output[:id] = rental.id
        price_per_km = rental.car.price_per_km
        distance = rental.distance

        number_of_days = (rental.end_date - rental.start_date + 1).to_i
        days_array = (1..number_of_days).to_a
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

        rental_price = total_daily_amount.reduce(0, :+) + distance * price_per_km
        output[:price] = rental_price.to_f
        if rental.deductible_reduction
          output[:options] = {deductible_reduction: (400 * number_of_days).to_f}
        else
          output[:options] = {deductible_reduction: 0}
        end

        commissions_hash = {}
        commissions_hash[:insurance_fee] = (0.3 * rental_price / 2).to_f
        commissions_hash[:assistance_fee] = (number_of_days * 100).to_f
        commissions_hash[:drivy_fee] = (commissions_hash[:insurance_fee] - commissions_hash[:assistance_fee]).to_f

        output[:commission] = commissions_hash
        @rentals << output
      end
    end
  end
end
