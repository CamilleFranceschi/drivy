require 'rails_helper'

RSpec.describe 'Rental Management', type: :request do

  describe "GET #index" do
    it "shows well calculated price" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: false)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2050, 3, 31), end_date: Date.new(2050, 4, 1), distance: 300, deductible_reduction: false)
      rental3 = Rental.create!(car: car1, start_date: Date.new(2050, 7, 3), end_date: Date.new(2050, 7, 14), distance: 1000, deductible_reduction: false)
      get "/api/v1/rentals"
      expect(response.body).to include("\"price\":3000.0")
      expect(response.body).to include("\"price\":6800.0")
      expect(response.body).to include("\"price\":27800.0")
    end

    it "shows well calculated commissions" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: false)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2050, 3, 31), end_date: Date.new(2050, 4, 1), distance: 300, deductible_reduction: false)
      rental3 = Rental.create!(car: car1, start_date: Date.new(2050, 7, 3), end_date: Date.new(2050, 7, 14), distance: 1000, deductible_reduction: false)
      get "/api/v1/rentals"
      expect(response.body).to include("\"commission\":{\"insurance_fee\":450.0,\"assistance_fee\":100.0,\"drivy_fee\":350.0}")
      expect(response.body).to include("\"commission\":{\"insurance_fee\":1020.0,\"assistance_fee\":200.0,\"drivy_fee\":820.0}")
      expect(response.body).to include("\"commission\":{\"insurance_fee\":4170.0,\"assistance_fee\":1200.0,\"drivy_fee\":2970.0}")
    end

    it "shows well calculated deductible reductions" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: true)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2050, 3, 31), end_date: Date.new(2050, 4, 1), distance: 300, deductible_reduction: false)
      rental3 = Rental.create!(car: car1, start_date: Date.new(2050, 7, 3), end_date: Date.new(2050, 7, 14), distance: 1000, deductible_reduction: true)
      get "/api/v1/rentals"
      expect(response.body).to include("\"deductible_reduction\":400")
      expect(response.body).to include("\"deductible_reduction\":0")
      expect(response.body).to include("\"deductible_reduction\":4800")
    end
  end
end
