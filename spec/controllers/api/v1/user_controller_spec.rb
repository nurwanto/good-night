require 'rails_helper'

RSpec.describe Api::V1::UserController, type: :controller do
  let(:current_user) { User.create!(name: 'Alice') }

  before do
    # Simulate authentication
    allow(controller).to receive(:authenticate!).and_return(true)
    controller.instance_variable_set(:@current_user, current_user)
  end

  describe 'GET #get_user_relations' do
    let(:follower_user) { User.create!(name: 'Bob') }
    let(:following_user) { User.create!(name: 'Charlie') }

    before do
      UserFollower.create!(follower: follower_user, following: current_user)
      UserFollower.create!(follower: current_user, following: following_user)
    end

    context 'when fetching followers' do
      it 'returns the list of followers with pagination' do
        allow_any_instance_of(Api::V1::UserService).to receive(:fetch_relations).and_return(
          {
            data: [ { id: follower_user.id, name: follower_user.name } ],
            pagination: {
              next_cursor: nil,
              previous_cursor: nil,
              per_page: 10
            }
          }
        )

        get :get_user_relations, params: { current_user_id: current_user.id, relation_type: 'followers', page_size: 10 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['id']).to eq(follower_user.id)
        expect(json_response['pagination']['next_cursor']).to be_nil
        expect(json_response['pagination']['previous_cursor']).to be_nil
        expect(json_response['pagination']['per_page']).to eq(10)
      end
    end

    context 'when fetching following' do
      it 'returns the list of following users with pagination' do
        allow_any_instance_of(Api::V1::UserService).to receive(:fetch_relations).and_return(
          {
            data: [ { id: following_user.id, name: following_user.name } ],
            pagination: {
              next_cursor: nil,
              previous_cursor: nil,
              per_page: 10
            }
          }
        )

        get :get_user_relations, params: { current_user_id: current_user.id, relation_type: 'following', page_size: 10 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['id']).to eq(following_user.id)
        expect(json_response['pagination']['next_cursor']).to be_nil
        expect(json_response['pagination']['previous_cursor']).to be_nil
        expect(json_response['pagination']['per_page']).to eq(10)
      end
    end

    context 'when relation_type is invalid' do
      it 'returns an error' do
        get :get_user_relations, params: { current_user_id: current_user.id, relation_type: 'invalid_type', page_size: 10 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('invalid relation_type, accepted relation_type value ["followers", "following"]')
      end
    end

    context 'when relation_type is missing' do
      it 'returns an error' do
        get :get_user_relations, params: { current_user_id: current_user.id, page_size: 10 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('relation_type should be exist')
      end
    end
  end

  describe 'POST #create_user_relations' do
    let(:target_user) { User.create!(name: 'Bob') }

    context 'when following a user' do
      it 'successfully follows the target user' do
        post :create_user_relations, params: { current_user_id: current_user.id, user_action: 'follow', target_user_id: target_user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq("you have successfully follow user #{target_user.id}")
      end

      it 'returns bad request when the target user is not found' do
        post :create_user_relations, params: { current_user_id: current_user.id, user_action: 'follow', target_user_id: 999 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq("Couldn't find User with 'id'=999")
      end
    end

    context 'when unfollowing a user' do
      it 'successfully unfollows the target user' do
        UserFollower.create!(follower: current_user, following: target_user)

        post :create_user_relations, params: { current_user_id: current_user.id, user_action: 'unfollow', target_user_id: target_user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq("you have successfully unfollow user #{target_user.id}")
      end
    end

    context 'when the target_user_id is missing' do
      it 'returns an error' do
        post :create_user_relations, params: { current_user_id: current_user.id, user_action: 'follow' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('target_user_id should be exist')
      end
    end

    context 'when the user_action is invalid' do
      it 'returns an error' do
        post :create_user_relations, params: { current_user_id: current_user.id, user_action: 'invalid_action', target_user_id: target_user.id }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('invalid user_actions, accepted user_action value ["follow", "unfollow"]')
      end
    end

    context 'when an exception is raised' do
      it 'returns an error message' do
        allow_any_instance_of(Api::V1::UserService).to receive(:create_relations).and_raise(StandardError, 'Something went wrong')

        post :create_user_relations, params: { current_user_id: current_user.id, user_action: 'follow', target_user_id: target_user.id }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('Something went wrong')
      end
    end
  end
end
