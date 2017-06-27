require 'rails_helper'

RSpec.describe 'Output Management', type: :request do

  describe "Rental Modifications" do
    before :each do
      RentalModification.destroy_all
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: true)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2050, 3, 31), end_date: Date.new(2050, 4, 1), distance: 300, deductible_reduction: false)
      rental3 = Rental.create!(car: car1, start_date: Date.new(2050, 7, 3), end_date: Date.new(2050, 7, 14), distance: 1000, deductible_reduction: true)
      rental_modification1 = RentalModification.create!(rental: rental1, end_date: Date.new(2050, 12, 10), distance: 150)
      rental_modification2 = RentalModification.create!(rental: rental3, start_date: Date.new(2050, 7, 4))
      get "/api/v1/rentals"
    end

    it "shows well calculated driver delta and type" do
      expect(response.body).to include("{\"who\":\"driver\",\"type\":\"debit\",\"amount\":4900.0}")
      expect(response.body).to include("{\"who\":\"driver\",\"type\":\"credit\",\"amount\":1400.0}")
    end

    it "shows well calculated owner delta and type" do
      expect(response.body).to include("{\"who\":\"owner\",\"type\":\"credit\",\"amount\":2870.0}")
      expect(response.body).to include("{\"who\":\"owner\",\"type\":\"debit\",\"amount\":700.0}")
    end

    it "shows well calculated insurance delta and type" do
      expect(response.body).to include("{\"who\":\"insurance\",\"type\":\"credit\",\"amount\":615.0}")
      expect(response.body).to include("{\"who\":\"insurance\",\"type\":\"debit\",\"amount\":150.0}")
    end

    it "shows well calculated assistance delta and type" do
      expect(response.body).to include("{\"who\":\"assistance\",\"type\":\"credit\",\"amount\":200.0}")
      expect(response.body).to include("{\"who\":\"assistance\",\"type\":\"debit\",\"amount\":100.0}")
    end

    it "shows well calculated drivy delta an type" do
      expect(response.body).to include("{\"who\":\"drivy\",\"type\":\"credit\",\"amount\":1215.0}]")
      expect(response.body).to include("{\"who\":\"drivy\",\"type\":\"debit\",\"amount\":450.0}]")
    end
  end
end
