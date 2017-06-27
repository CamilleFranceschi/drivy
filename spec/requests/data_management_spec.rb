require 'rails_helper'

RSpec.describe 'Data Management', type: :request do

  describe "Cars" do
    it "shows the newly cars created" do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      get "/api/v1/cars"
      expect(response.body).to include("\"price_per_day\":2000,\"price_per_km\":10")
      expect(response.body).to include("\"price_per_day\":3000,\"price_per_km\":15")
    end
  end

  describe "Rentals" do

    before :each do
      Rental.destroy_all
      Car.destroy_all
      @car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
    end

    it "shows the newly rentals created" do
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      rental1 = Rental.create!(car: @car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 100, deductible_reduction: true )
      rental2 = Rental.create!(car: car2, start_date: Date.new(2050, 12, 14), end_date: Date.new(2050, 12, 18), distance: 550, deductible_reduction: true)
      get "/api/v1/cars"
      expect(response.body).to include("\"start_date\":\"2050-12-08\",\"end_date\":\"2050-12-12\",\"distance\":100")
      expect(response.body).to include("\"start_date\":\"2050-12-14\",\"end_date\":\"2050-12-18\",\"distance\":550")
    end

    it "shows the rentals of two different cars booked at the same time" do
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      rental1 = Rental.create!(car: @car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 100, deductible_reduction: false)
      rental2 = Rental.create!(car: car2, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 150, deductible_reduction: false)
      get "/api/v1/cars"
      expect(response.body).to include("\"price_per_day\":2000,\"price_per_km\":10")
      expect(response.body).to include("\"price_per_day\":3000,\"price_per_km\":15")
      expect(response.body).to include("\"start_date\":\"2050-12-08\",\"end_date\":\"2050-12-12\",\"distance\":100")
      expect(response.body).to include("\"start_date\":\"2050-12-08\",\"end_date\":\"2050-12-12\",\"distance\":150")
    end

    it "raises an error if dates are from the past" do
      get "/api/v1/cars"
      expect{Rental.create!(car: @car1, start_date: Date.new(2016, 12, 14), end_date: Date.new(2016, 12, 18), distance: 550, deductible_reduction: false)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Start date can\'t be in the past')
    end

    it "raises an error if end date is before start date" do
      get "/api/v1/cars"
      expect{Rental.create!(car: @car1, start_date: Date.new(2050, 12, 10), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: false)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: End date must be after the start date')
    end

    it "raises an error when booking dates are not available" do
      rental1 = Rental.create!(car: @car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 100, deductible_reduction: false)
      get "/api/v1/cars"
      expect{Rental.create!(car: @car1, start_date: Date.new(2050, 12, 9), end_date: Date.new(2050, 12, 11), distance: 150, deductible_reduction: false)}.to raise_error(ActiveRecord::RecordInvalid,'Validation failed: Start date is not available')
    end
  end

  describe "Rental Modfifications" do

    before :each do
      RentalModification.destroy_all
      Rental.destroy_all
      Car.destroy_all
      @car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      @rental1 = Rental.create!(car: @car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 100, deductible_reduction: false )
    end

    it "shows the newly rental modifications created" do
      modification = RentalModification.create!(rental: @rental1, start_date: Date.new(2050, 12, 6) )
      get "/api/v1/cars"
      expect(response.body).to include("\"start_date\":\"2050-12-06\"")
    end

    it "shows the same rental modifications of two different rentals" do
      car2 = Car.create!(price_per_day: 3000, price_per_km: 15)
      rental2 = Rental.create!(car: car2, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 12), distance: 150, deductible_reduction: false)
      modification1 = RentalModification.create!(rental: @rental1, start_date: Date.new(2050, 12, 6), distance: 110)
      modification2 = RentalModification.create!(rental: rental2, start_date: Date.new(2050, 12, 6), distance: 120)
      get "/api/v1/cars"
      expect(response.body).to include("\"start_date\":\"2050-12-06\",\"distance\":110")
      expect(response.body).to include("\"start_date\":\"2050-12-06\",\"distance\":120")
    end

    it "raises an error if new start date is from the past" do
      get "/api/v1/cars"
      expect{RentalModification.create!(rental: @rental1, start_date: Date.new(2015, 12, 6), distance: 110)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Start date can\'t be in the past')
    end

    it "raises an error if end date is before start date" do
      get "/api/v1/cars"
      expect{RentalModification.create!(rental: @rental1, start_date: Date.new(2050, 12, 6), end_date: Date.new(2050, 12, 4), distance: 110)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: End date must be after the start date')
    end

    it "raises an error when booking dates are not available" do
      rental2 = Rental.create!(car: @car1, start_date: Date.new(2050, 12, 15), end_date: Date.new(2050, 12, 20), distance: 100, deductible_reduction: false)
      get "/api/v1/cars"
      expect{RentalModification.create!(rental: rental2, start_date: Date.new(2050, 12, 9))}.to raise_error(ActiveRecord::RecordInvalid,'Validation failed: Start date is not available')
    end
  end
end
