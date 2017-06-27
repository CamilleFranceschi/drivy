class Api::V1::CarsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: :index
  def index
    @cars = policy_scope(Car)
    @rentals = []
    @rental_modifications = []
     @cars.each do |car|
       car.rentals.each do |rental|
        @rentals << rental
        if rental.rental_modification
           @rental_modifications << rental.rental_modification
         end
       end
    end
  end
end
