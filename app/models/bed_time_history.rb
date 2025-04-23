class BedTimeHistory < ApplicationRecord
  before_save :calculate_sleep_duration
  after_create :populate_metadata
  belongs_to :user

  private

  def calculate_sleep_duration
    if bed_time.present? && wake_up_time.present?
      self.sleep_duration = (wake_up_time - bed_time).to_i
    else
      self.sleep_duration = 0
    end
  end

  def populate_metadata
    self.update_column(:metadata, { username: user.name })
  end
end
