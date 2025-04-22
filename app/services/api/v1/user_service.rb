module Api
  module V1
    class UserService
      def initialize(current_user, params)
        @current_user = current_user
        @params = params
      end

      def fetch_relations
        validate_relation_type!

        page_size = @params[:page_size].to_i > 0 ? @params[:page_size].to_i : 10

        case @params[:relation_type].to_s
        when 'followers'
          query = @current_user.followers.order('user_followers.id DESC')
        when 'following'
          query = @current_user.following.order('user_followers.id DESC')
        else
          raise StandardError, 'invalid relation_type, accepted relation_type value ["followers", "following"]'
        end

        # Apply cursor-based pagination
        query = query.where('users.id < ?', @params[:page_after]) if @params[:page_after].present?
        query = query.where('users.id > ?', @params[:page_before]) if @params[:page_before].present?

        # Fetch one extra record to determine `has_more`
        paginated_data = query.limit(page_size + 1).to_a
        has_more = paginated_data.size > page_size
        paginated_data = paginated_data.first(page_size)

        previous_cursor = @params[:page_after].present? ? paginated_data.first&.id : nil
        next_cursor = has_more || @params[:page_before].present? ? paginated_data.last&.id : nil

        {
          data: paginated_data,
          pagination: {
            next_cursor: next_cursor,
            previous_cursor: previous_cursor,
            per_page: page_size
          }
        }
      end

      def create_relations
        validate_user_action!

        raise StandardError, 'target_user_id should be exist' if @params[:target_user_id].blank?
        raise StandardError, 'you cannot follow yourself' if @params[:target_user_id] == @params[:current_user_id]
        target_user = User.find(@params[:target_user_id])

        case @params[:user_action].to_s
        when 'follow'
          raise StandardError, "you are already following user #{target_user.id}" if UserFollower.find_by(
            follower_id: @current_user.id, following_id: target_user.id
          )

          UserFollower.create!(follower_id: @current_user.id, following_id: target_user.id)
        when 'unfollow'
          user_follower = UserFollower.find_by(follower_id: @current_user.id, following_id: target_user.id)
          raise StandardError, "you are not following user #{target_user.id}" if user_follower.blank?

          user_follower.destroy!
        else
          raise StandardError, 'invalid action, accepted user_action value ["follow", "unfollow"]'
        end
      end

      private

      def validate_relation_type!
        raise StandardError, 'relation_type should be exist' if @params[:relation_type].blank?

        valid_types = %w[followers following]
        unless valid_types.include?(@params[:relation_type].to_s)
          raise StandardError, 'invalid relation_type, accepted relation_type value ["followers", "following"]'
        end
      end

      def validate_user_action!
        raise StandardError, 'user_action should be exist' if @params[:user_action].blank?

        valid_actions = %w[follow unfollow]
        unless valid_actions.include?(@params[:user_action].to_s)
          raise StandardError, 'invalid user_actions, accepted user_action value ["follow", "unfollow"]'
        end
      end
    end
  end
end
