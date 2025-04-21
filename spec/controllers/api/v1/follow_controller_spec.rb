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
end
