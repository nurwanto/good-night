module Api
  module V1
    class BedTimeController < ApplicationController
      before_action :authenticate!

      include Api::V1::GeneralHelper
      protect_from_forgery with: :null_session

      rescue_from StandardError, ArgumentError do |e|
        render json: { error_message: e.message },
              status: :bad_request
      end

      def history
        result = Api::V1::BedTimeService.new(@current_user, params).fetch_histories

        render json: {
          data: result[:data],
          pagination: result[:pagination]
        }
      end

      def set_unset
        setup_time = Api::V1::BedTimeService.new(@current_user, params).set_sleep_time

        render json: { message: "#{params[:type]} successfully set at #{setup_time}" }
      end
    end
  end
end
