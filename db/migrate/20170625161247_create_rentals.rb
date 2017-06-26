class CreateRentals < ActiveRecord::Migration[5.0]
  def change
    create_table :rentals do |t|
      t.date :start_date
      t.date :end_date
      t.integer :distance
      t.references :car, foreign_key: true

      t.timestamps
    end
  end
end
