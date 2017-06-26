class Api::V1::RentalsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: :index
  def index
    cars = policy_scope(Car)
    @rentals = []
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
        if rental.deductible_reduction
          deductible_reduction = 400 * number_of_days
        else
          deductible_reduction = 0
        end

        owner_fee = (0.7 * rental_price).to_f
        insurance_fee = (0.3 * rental_price / 2).to_f
        assistance_fee = (number_of_days * 100).to_f

        output[:actions]= [
          {
            "who": "driver",
            "type": "debit",
            "amount": (rental_price + deductible_reduction).to_f
          },
          {
            "who": "owner",
            "type": "credit",
            "amount": owner_fee
          },
          {
            "who": "insurance",
            "type": "credit",
            "amount": insurance_fee
          },
          {
            "who": "assistance",
            "type": "credit",
            "amount": assistance_fee
          },
          {
            "who": "drivy",
            "type": "credit",
            "amount": (insurance_fee - assistance_fee + deductible_reduction).to_f
          }
        ]
        @rentals << output
      end
    end
  end
end
