class BedTimeHistory < ApplicationRecord
  before_save :calculate_sleep_duration
  belongs_to :user

  private

  def calculate_sleep_duration
    if bed_time.present? && wake_up_time.present?
      self.sleep_duration = (wake_up_time - bed_time).to_i
    else
      self.sleep_duration = 0
    end
  end
end
