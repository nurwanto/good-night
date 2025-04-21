require 'rails_helper'

RSpec.describe Api::V1::FollowController, type: :controller do
  describe 'GET #get_followers' do
    let(:user) { User.create!(name: 'Alice') }
    let(:follower1) { User.create!(name: 'Bob') }
    let(:follower2) { User.create!(name: 'Charlie') }

    before do
      # Simulate authentication
      allow(controller).to receive(:authenticate!).and_return(true)
      controller.instance_variable_set(:@current_user, user)

      # Add followers to the user
      user.followers << [follower1, follower2]
    end

    context 'when the user is authenticated' do
      it 'returns the list of followers' do
        get :get_followers, params: { current_user_id: user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].size).to eq(2)
        expect(json_response['data']).to include(follower1.as_json, follower2.as_json)
      end
    end
  end

  describe 'GET #get_followed' do
    let(:user) { User.create!(name: 'Alice') }
    let(:followed1) { User.create!(name: 'Bob') }
    let(:followed2) { User.create!(name: 'Charlie') }

    before do
      # Simulate authentication
      allow(controller).to receive(:authenticate!).and_return(true)
      controller.instance_variable_set(:@current_user, user)

      # Add followed users to the user
      user.followed << [followed1, followed2]
    end

    context 'when the user is authenticated' do
      it 'returns the list of followed users' do
        get :get_followed

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data'].size).to eq(2)
        expect(json_response['data']).to include(followed1.as_json, followed2.as_json)
      end
    end
  end

  describe 'POST #action' do
    let(:user) { User.create!(name: 'Alice') }
    let(:target_user) { User.create!(name: 'Bob') }

    before do
      # Simulate authentication
      allow(controller).to receive(:authenticate!).and_return(true)
      controller.instance_variable_set(:@current_user, user)
    end

    context 'when target_user_id is not provided' do
      it 'raises a StandardError' do
        post :action, params: { current_user_id: user.id, user_action: 'follow' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error_message']).to eq('target_user_id should be exist')
      end
    end

    context 'when trying to follow yourself' do
      it 'raises a StandardError' do
        post :action, params: { current_user_id: user.id, target_user_id: user.id, user_action: 'follow' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error_message']).to eq('you cannot follow yourself')
      end
    end

    context 'when trying to follow a user you are already following' do
      before do
        UserFollower.create!(follower_id: user.id, followed_id: target_user.id)
      end

      it 'raises a StandardError' do
        post :action, params: { current_user_id: user.id, target_user_id: target_user.id, user_action: 'follow' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error_message']).to eq("you are already following user #{target_user.id}")
      end
    end

    context 'when successfully following a user' do
      it 'creates a UserFollower record and returns a success message' do
        post :action, params: { current_user_id: user.id, target_user_id: target_user.id, user_action: 'follow' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("you have successfully follow user #{target_user.id}")
        expect(UserFollower.find_by(follower_id: user.id, followed_id: target_user.id)).not_to be_nil
      end
    end

    context 'when trying to unfollow a user you are not following' do
      it 'raises a StandardError' do
        post :action, params: { current_user_id: user.id, target_user_id: target_user.id, user_action: 'unfollow' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error_message']).to eq("you are not following user #{target_user.id}")
      end
    end

    context 'when successfully unfollowing a user' do
      before do
        UserFollower.create!(follower_id: user.id, followed_id: target_user.id)
      end

      it 'destroys the UserFollower record and returns a success message' do
        post :action, params: { current_user_id: user.id, target_user_id: target_user.id, user_action: 'unfollow' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("you have successfully unfollow user #{target_user.id}")
        expect(UserFollower.find_by(follower_id: user.id, followed_id: target_user.id)).to be_nil
      end
    end

    context 'when an invalid action is provided' do
      it 'raises a StandardError' do
        post :action, params: { current_user_id: user.id, target_user_id: target_user.id, user_action: 'invalid_action' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error_message']).to eq('invalid action, accepted action value ["follow", "unfollow"]')
      end
    end
  end
end
