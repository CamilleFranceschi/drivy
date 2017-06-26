class Api::V1::CarsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: :index
  def index
    @cars = policy_scope(Car)
    @rentals = []
     @cars.each do |car|
       car.rentals.each do |rental|
         @rentals << rental
       end
    end
  end
end
