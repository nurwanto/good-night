module Api::V1::GeneralHelper
  def authenticate!
    # NOTE: using this parameter to simulate the authentication
    raise ArgumentError, "current_user_id should be exist" if params[:current_user_id].blank?

    @current_user = User.find_by(id: params[:current_user_id])
    raise StandardError, "Authentication failed, user_id #{params[:current_user_id]} not exist" if @current_user.blank?

    @current_user
  end
end
