class RentalModification < ApplicationRecord
  belongs_to :rental
  validates_uniqueness_of :rental_id

  validate :end_after_start
  validate :start_before_end
  validate :start_date_cannot_be_in_the_past
  validate :validate_booking_dates

  private

  def end_after_start
    if end_date && start_date && end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end

    if end_date && start_date == nil
      if end_date < Rental.find(rental_id).start_date
        errors.add(:end_date, "must be after the start date")
      end
    end
  end

  def start_before_end
    if start_date && end_date == nil
      if start_date > Rental.find(rental_id).end_date
        errors.add(:start_date, "must be before the end date")
      end
    end
  end

  def start_date_cannot_be_in_the_past
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "can't be in the past")
    end
  end

  def validate_booking_dates
    @rentals = Rental.all.where.not(id: rental_id)
    @dates = []
    @rentals.each do |rental|
      if Rental.find(rental_id).car_id == rental.car.id
        @dates << (rental.start_date..rental.end_date).to_a
      end
    end
    @dates.flatten!
    if start_date.present? && @dates.include?(start_date)
      errors.add(:start_date, "is not available")
    elsif start_date.present? && end_date.present? && @dates.include?(end_date)
      errors.add(:end_date, "is not available")
    elsif start_date.present? && end_date.present? && ( (@dates - (start_date..end_date).to_a).length != @dates.length )
      errors.add(:start_date,"Dates are not available")
    end
  end
end
