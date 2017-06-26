class AddDeductibleReductionToRentals < ActiveRecord::Migration[5.0]
  def change
    add_column :rentals, :deductible_reduction, :boolean
  end
end
