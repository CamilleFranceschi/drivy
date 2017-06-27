class Api::V1::RentalsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: :index


  def index

    cars = policy_scope(Car)

    cars.each do |car|
      @rental_modifications = []
      car.rentals.each do |rental|

        price_per_km = rental.car.price_per_km
        distance_before = rental.distance

        number_of_days_before = (rental.end_date - rental.start_date + 1).to_i

        if rental.rental_modification
          if rental.rental_modification.start_date && rental.rental_modification.end_date
            number_of_days_after = (rental.rental_modification.end_date - rental.rental_modification.start_date  + 1).to_i
          elsif rental.rental_modification.start_date && rental.rental_modification.end_date == nil
            number_of_days_after = (rental.end_date - rental.rental_modification.start_date + 1).to_i
          else rental.rental_modification.start_date == nil && rental.rental_modification.end_date
            number_of_days_after = (rental.rental_modification.end_date - rental.start_date  + 1).to_i
          end
        else
          number_of_days_after = number_of_days_before
        end

        days_array_before = (1..number_of_days_before).to_a
        total_daily_amount_before = days_array_before.map do |day|
          pricing(day, rental)
        end

        days_array_after = (1..number_of_days_after).to_a
        total_daily_amount_after = days_array_after.map do |day|
          pricing(day, rental)
        end

        rental_price_before = total_daily_amount_before.reduce(0, :+) + distance_before * price_per_km

        if rental.rental_modification
          if rental.rental_modification.distance
            distance_after = rental.rental_modification.distance
            rental_price_after = total_daily_amount_after.reduce(0, :+) + distance_after * price_per_km
          else
            rental_price_after = total_daily_amount_after.reduce(0, :+) + distance_before * price_per_km
          end
        else
          rental_price_after = rental_price_before
        end

        if rental.deductible_reduction
          delta_deductible_reduction = 400 * (number_of_days_after -  number_of_days_before)
        else
          delta_deductible_reduction = 0
        end

        delta_driver = - (rental_price_after + delta_deductible_reduction - rental_price_before).to_f
        delta_owner = (0.7 * (rental_price_after - rental_price_before)).to_f
        delta_insurance = (0.3 * (rental_price_after - rental_price_before) / 2).to_f
        delta_assistance = ((number_of_days_after - number_of_days_before) * 100).to_f
        delta_drivy = (delta_insurance - delta_assistance + delta_deductible_reduction).to_f

        if rental.rental_modification
          output = {}
          output[:id] = rental.rental_modification.id
          output[:rental_id] = rental.rental_modification.rental_id
          output[:actions]= [
          {
            "who": "driver",
            "type": type(delta_driver),
            "amount": delta_driver.abs
          },
          {
            "who": "owner",
            "type": type(delta_owner),
            "amount": delta_owner.abs
          },
          {
            "who": "insurance",
            "type": type(delta_insurance),
            "amount": delta_insurance.abs
          },
          {
            "who": "assistance",
            "type": type(delta_assistance),
            "amount": delta_assistance.abs
          },
          {
            "who": "drivy",
            "type": type(delta_drivy),
            "amount": delta_drivy.abs
          }
        ]
        end
        @rental_modifications << output
      end
    end
  end

  private

  def pricing(day, rental)
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

  def type(amount)
    amount > 0 ? "credit" : "debit"
  end
end
