require 'rails_helper'

RSpec.describe 'Car Management', type: :request do

  describe "GET #index" do
    it "shows the newly cars and and rentals created" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 10), distance: 100, deductible_reduction: true )
      rental2 = Rental.create!(car: car2, start_date: Date.new(2050, 12, 14), end_date: Date.new(2050, 12, 18), distance: 550, deductible_reduction: true)
      get "/api/v1/cars"
      expect(response.body).to include("\"price_per_day\":2000,\"price_per_km\":10")
      expect(response.body).to include("\"price_per_day\":3000,\"price_per_km\":15")
      expect(response.body).to include("\"start_date\":\"2050-12-08\",\"end_date\":\"2050-12-10\",\"distance\":100")
      expect(response.body).to include("\"start_date\":\"2050-12-14\",\"end_date\":\"2050-12-18\",\"distance\":550")
    end

    it "shows the rentals of two different cars booked at the same time" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 10), distance: 100, deductible_reduction: false)
      rental2 = Rental.create!(car: car2, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 10), distance: 150, deductible_reduction: false)
      get "/api/v1/cars"
      expect(response.body).to include("\"price_per_day\":2000,\"price_per_km\":10")
      expect(response.body).to include("\"price_per_day\":3000,\"price_per_km\":15")
      expect(response.body).to include("\"start_date\":\"2050-12-08\",\"end_date\":\"2050-12-10\",\"distance\":100")
      expect(response.body).to include("\"start_date\":\"2050-12-08\",\"end_date\":\"2050-12-10\",\"distance\":150")
    end

    it "raises an error when booking dates are not available" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 100, deductible_reduction: false)
      get "/api/v1/cars"
      expect{Rental.create!(car: car1, start_date: Date.new(2050, 12, 9), end_date: Date.new(2050, 12, 11), distance: 150, deductible_reduction: false)}.to raise_error(ActiveRecord::RecordInvalid,'Validation failed: Start date is not available')
    end

    it "raises an error if dates are from the past" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      get "/api/v1/cars"
      expect{Rental.create!(car: car1, start_date: Date.new(2016, 12, 14), end_date: Date.new(2016, 12, 18), distance: 550, deductible_reduction: false)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Start date can\'t be in the past')
    end

    it "raises an error if end date is before start date" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      get "/api/v1/cars"
      expect{Rental.create!(car: car1, start_date: Date.new(2050, 12, 10), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: false)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: End date must be after the start date')
    end
  end
end
