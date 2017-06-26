require 'rails_helper'

RSpec.describe 'Rental Management', type: :request do

  describe "GET #index" do
    it "shows well calculated price" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2017, 12, 8), end_date: Date.new(2017, 12, 10), distance: 100)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2017, 12, 14), end_date: Date.new(2017, 12, 18), distance: 550)
      rental3 = Rental.create!(car: car2, start_date: Date.new(2017, 12, 8), end_date: Date.new(2017, 12, 10), distance: 150)
      get "/api/v1/rentals"
      expect(response.body).to include("\"price\":7000")
      expect(response.body).to include("\"price\":15500")
      expect(response.body).to include("\"price\":11250")
    end
  end
end
