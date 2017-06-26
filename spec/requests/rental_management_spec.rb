require 'rails_helper'

RSpec.describe 'Rental Management', type: :request do

  describe "GET #index" do
    before :each do
      Rental.destroy_all
      Car.destroy_all
      car1 = Car.create!(price_per_day: 2000, price_per_km: 10)
      rental1 = Rental.create!(car: car1, start_date: Date.new(2050, 12, 8), end_date: Date.new(2050, 12, 8), distance: 100, deductible_reduction: true)
      rental2 = Rental.create!(car: car1, start_date: Date.new(2050, 3, 31), end_date: Date.new(2050, 4, 1), distance: 300, deductible_reduction: false)
      rental3 = Rental.create!(car: car1, start_date: Date.new(2050, 7, 3), end_date: Date.new(2050, 7, 14), distance: 1000, deductible_reduction: true)
      get "/api/v1/rentals"
    end

    it "shows well calculated driver cost" do
      expect(response.body).to include("{\"who\":\"driver\",\"type\":\"debit\",\"amount\":3400.0}")
      expect(response.body).to include("{\"who\":\"driver\",\"type\":\"debit\",\"amount\":6800.0}")
      expect(response.body).to include("{\"who\":\"driver\",\"type\":\"debit\",\"amount\":32600.0}")
    end

    it "shows well calculated owner fee" do
      expect(response.body).to include("{\"who\":\"owner\",\"type\":\"credit\",\"amount\":2100.0}")
      expect(response.body).to include("{\"who\":\"owner\",\"type\":\"credit\",\"amount\":4760.0}")
      expect(response.body).to include("{\"who\":\"owner\",\"type\":\"credit\",\"amount\":19460.0}")
    end

    it "shows well calculated insurance fee" do
      expect(response.body).to include("{\"who\":\"insurance\",\"type\":\"credit\",\"amount\":450.0}")
      expect(response.body).to include("{\"who\":\"insurance\",\"type\":\"credit\",\"amount\":1020.0}")
      expect(response.body).to include("{\"who\":\"insurance\",\"type\":\"credit\",\"amount\":4170.0}")
    end

    it "shows well calculated assistance fee" do
      expect(response.body).to include("{\"who\":\"assistance\",\"type\":\"credit\",\"amount\":100.0}")
      expect(response.body).to include("{\"who\":\"assistance\",\"type\":\"credit\",\"amount\":200.0}")
      expect(response.body).to include("{\"who\":\"assistance\",\"type\":\"credit\",\"amount\":1200.0}")
    end

    it "shows well calculated drivy fee" do
      expect(response.body).to include("{\"who\":\"drivy\",\"type\":\"credit\",\"amount\":750.0}]")
      expect(response.body).to include("{\"who\":\"drivy\",\"type\":\"credit\",\"amount\":820.0}]")
      expect(response.body).to include("{\"who\":\"drivy\",\"type\":\"credit\",\"amount\":7770.0}]")
    end
  end
end
