require 'rails_helper'

RSpec.describe 'Rental Management', type: :request do

  describe "GET #index" do
    it "shows well calculated price" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 8), distance: 100)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2050, 3, 31), end_date: Date.new(2050, 4, 1), distance: 300)
      rental3 = Rental.create!(car: car1, start_date: Date.new(2050, 7, 3), end_date: Date.new(2050, 7, 14), distance: 1000)
      get "/api/v1/rentals"
      expect(response.body).to include("\"price\":3000")
      expect(response.body).to include("\"price\":6800")
      expect(response.body).to include("\"price\":27800")
    end
  end
end
