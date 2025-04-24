class ApplicationService
  def with_retry_on_deadlock
    retries ||= 0
    yield
  rescue ActiveRecord::Deadlocked => e
    retries += 1
    retry if retries < 3
    Rails.logger.error("Deadlock detected, max retry attempts reached. Raising: #{e.message}")
    raise StandardError, "Deadlock detected, max retry attempts reached. #{e.message}"
  end
end
