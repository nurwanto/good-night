module Api
  module V1
    class FollowController < ApplicationController
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

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error_message: e.message },
               status: :not_found
      end

      def get_followers
        render json: { data: @current_user.followers }
      end
    end
  end
end
