module Api
  module V1
    class UserController < ApplicationController
      before_action :authenticate!

      include Api::V1::GeneralHelper
      protect_from_forgery with: :null_session

      rescue_from ArgumentError, ActiveRecord::RecordNotFound do |e|
        render json: { error_message: e.message },
               status: :not_found
      end

      rescue_from StandardError do |e|
        render json: { error_message: e.message },
               status: :bad_request
      end

      def get_user_relations
        result = Api::V1::UserService.new(@current_user, params).fetch_relations

        render json: {
          data: result[:data],
          pagination: result[:pagination]
        }
      end

      def create_user_relations
        Api::V1::UserService.new(@current_user, params).create_relations

        render json: { message: "you have successfully #{params[:user_action]} user #{params[:target_user_id]}" }
      end
    end
  end
end
