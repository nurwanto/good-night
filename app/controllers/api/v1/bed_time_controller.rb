module Api
  module V1
    class BedTimeController < ApplicationController
      before_action :authenticate!

      include Api::V1::GeneralHelper
      protect_from_forgery with: :null_session

      rescue_from ArgumentError do |e|
        render json: { error_message: e.message },
               status: :not_found
      end

      rescue_from StandardError do |e|
        render json: { error_message: e.message },
               status: :bad_request
      end

      def history
        page_size = params[:page_size].to_i > 0 ? params[:page_size].to_i : 10
        cursor_duration, cursor_id = params[:cursor]&.split('-')

        query = BedTimeHistory
                  .joins('INNER JOIN user_followers uf ON bed_time_histories.user_id = uf.followed_id')
                  .where('bed_time_histories.created_at >= ? AND uf.follower_id = ?', 1.week.ago, @current_user.id)
                  .select('bed_time_histories.id, bed_time_histories.user_id, bed_time_histories.bed_time, bed_time_histories.wake_up_time, bed_time_histories.sleep_duration')
                  .order('bed_time_histories.sleep_duration DESC, bed_time_histories.id DESC')

        if cursor_duration.present? && cursor_id.present?
          query = query.where(
            '(bed_time_histories.sleep_duration < ?) OR (bed_time_histories.sleep_duration = ? AND bed_time_histories.id < ?)',
            cursor_duration, cursor_duration, cursor_id
          )
        end

        data = query.limit(page_size)
        next_cursor = data.size < page_size ? nil : "#{data.last.sleep_duration}-#{data.last.id}"

        render json: {
          data: data.map do |x|
            {
              id: x.id,
              user_id: x.user_id,
              bed_time: x.bed_time,
              wake_up_time: x.wake_up_time,
              duration: x.sleep_duration
            }
          end,
          meta: {
            next_cursor: next_cursor,
            page_size: page_size
          }
        }
      end

      def set_unset
        current_time = Time.now
        case params[:type].to_s
        when 'bed_time'
          unless @current_user.bed_time_histories&.last&.wake_up_time.present?
            raise StandardError, "you haven't woken up yet"
          end

          BedTimeHistory.create!(bed_time: current_time, user_id: @current_user.id)
        when 'wake_up'
          last_history = @current_user.bed_time_histories&.last
          unless last_history&.bed_time.present? && last_history&.wake_up_time.blank?
            raise StandardError, "you haven't slept yet"
          end

          last_history.update!(wake_up_time: current_time)
        else
          raise StandardError, 'invalid type, accepted value ["bed_time", "wake_up"]'
        end

        render json: { message: "#{params[:type]} successfully set at #{current_time}" }
      end
    end
  end
end
