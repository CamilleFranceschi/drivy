class CreateRentalModifications < ActiveRecord::Migration[5.0]
  def change
    create_table :rental_modifications do |t|
      t.date :start_date
      t.date :end_date
      t.integer :distance
      t.references :rental, foreign_key: true

      t.timestamps
    end
  end
end
