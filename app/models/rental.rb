class Rental < ApplicationRecord
  belongs_to :car
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :distance, presence: true

  validate :end_after_start
  validate :start_date_cannot_be_in_the_past
  validate :validate_booking_dates

  private

  def end_after_start
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def start_date_cannot_be_in_the_past
    if start_date.present? && start_date < Date.today
      errors.add(:start_date, "can't be in the past")
    end
  end

  def validate_booking_dates
    @rentals = Rental.all
    @dates = []
    @rentals.each do |rental|
      if car_id == rental.car.id
      @dates << (rental.start_date..rental.end_date).to_a
    end
    end
    @dates.flatten!
    if start_date.present? && @dates.include?(start_date)
      errors.add(:start_date, "is not available")
    elsif start_date.present? && end_date.present? && @dates.include?(end_date)
      errors.add(:end_date, "is not available")
    elsif start_date.present? && end_date.present? && ( (@dates - (start_date..end_date).to_a ).length != @dates.length )
      errors.add(:start_date,"Dates are not available")
    end
  end
end
