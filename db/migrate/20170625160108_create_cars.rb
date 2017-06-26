class CreateCars < ActiveRecord::Migration[5.0]
  def change
    create_table :cars do |t|
      t.integer :price_per_day
      t.integer :price_per_km

      t.timestamps
    end
  end
end
