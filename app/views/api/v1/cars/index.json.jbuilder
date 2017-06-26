json.cars do
  json.array! @cars.each  do  |car|
    json.extract! car, :id, :price_per_day, :price_per_km
  end
end

json.rentals  @rentals.each do |rental|
  json.extract! rental, :id, :car_id, :start_date, :end_date, :distance, :deductible_reduction
end
