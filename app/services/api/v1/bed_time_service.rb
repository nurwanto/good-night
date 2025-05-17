module Api
  module V1
    class BedTimeService < ApplicationService
      def initialize(current_user, params)
        @current_user = current_user
        @params = params
      end

      def fetch_histories
        page_size = @params[:page_size].to_i > 0 ? @params[:page_size].to_i : 10
        next_cursor_duration, next_cursor_id = @params[:page_after]&.split("-")
        prev_cursor_duration, prev_cursor_id = @params[:page_before]&.split("-")

        query = BedTimeHistory
                  .joins("INNER JOIN user_followers uf ON bed_time_histories.user_id = uf.following_id")
                  .where("bed_time_histories.created_at >= ? AND uf.follower_id = ?", 1.week.ago, @current_user.id)
                  .select("bed_time_histories.id, bed_time_histories.user_id, bed_time_histories.bed_time, bed_time_histories.wake_up_time, bed_time_histories.sleep_duration_in_sec, bed_time_histories.metadata")
                  .order("bed_time_histories.sleep_duration_in_sec DESC, bed_time_histories.id DESC")

        # Apply cursor-based pagination
        if next_cursor_duration.present? && next_cursor_id.present?
          query = query.where(
            "(bed_time_histories.sleep_duration_in_sec < ?) OR (bed_time_histories.sleep_duration_in_sec = ? AND bed_time_histories.id < ?)",
            next_cursor_duration, next_cursor_duration, next_cursor_id
          )
        elsif prev_cursor_duration.present? && prev_cursor_id.present?
          query = query.where(
            "(bed_time_histories.sleep_duration_in_sec > ?) OR (bed_time_histories.sleep_duration_in_sec = ? AND bed_time_histories.id > ?)",
            prev_cursor_duration, prev_cursor_duration, prev_cursor_id
          )
        end

        # Fetch paginated data
        paginated_data = query.limit(page_size + 1).to_a
        has_more = paginated_data.size > page_size
        paginated_data = paginated_data.first(page_size)

        # Generate cursors
        previous_cursor = @params[:page_after].present? ? "#{paginated_data.first&.sleep_duration_in_sec}-#{paginated_data.first&.id}" : nil
        next_cursor = has_more || @params[:page_before].present? ? "#{paginated_data.last&.sleep_duration_in_sec}-#{paginated_data.last&.id}" : nil

        {
          data: paginated_data.map do |x|
            {
              id: x.id,
              user_id: x.user_id,
              user_name: x.metadata["username"],
              bed_time: x.bed_time,
              wake_up_time: x.wake_up_time,
              duration: x.sleep_duration_in_sec
            }
          end,
          pagination: {
            next_cursor: next_cursor,
            previous_cursor: previous_cursor,
            page_size: page_size
          }
        }
      end

      def set_sleep_time
        current_time = Time.now

        with_retry_on_deadlock do
          case @params[:type].to_s
          when "bed_time"
            handle_bed_time(current_time)
          when "wake_up"
            handle_wake_up(current_time)
          else
            raise StandardError, 'invalid type, accepted value ["bed_time", "wake_up"]'
          end
        end

        current_time
      end

      private

      def handle_bed_time(current_time)
        BedTimeHistory.transaction do
          last_history = @current_user.bed_time_histories.order(id: :desc).limit(1).lock(true).first

          if last_history && last_history.wake_up_time.blank?
            raise StandardError, "you haven't woken up yet"
          end

          BedTimeHistory.create!(bed_time: current_time, user_id: @current_user.id)
        end
      end

      def handle_wake_up(current_time)
        BedTimeHistory.transaction do
          last_history = @current_user.bed_time_histories.order(id: :desc).limit(1).lock(true).first

          unless last_history&.bed_time.present? && last_history.wake_up_time.blank?
            raise StandardError, "you haven't slept yet"
          end

          last_history.update!(wake_up_time: current_time)
        end
      end
    end
  end
end
