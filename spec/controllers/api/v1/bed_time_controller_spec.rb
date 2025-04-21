require 'rails_helper'

RSpec.describe Api::V1::BedTimeController, type: :controller do
  let(:current_user) { User.create!(name: 'Alice') }
  let(:followed_user) { User.create!(name: 'Bob') }
  let!(:bed_time_histories) do
    [
      BedTimeHistory.create!(user: followed_user, bed_time: 10.hours.ago, wake_up_time: 2.hours.ago), # 8 hours
      BedTimeHistory.create!(user: followed_user, bed_time: 12.hours.ago, wake_up_time: 6.hours.ago), # 6 hours
      BedTimeHistory.create!(user: followed_user, bed_time: 13.hours.ago, wake_up_time: 6.hours.ago)  # 7 hours
    ]
  end

  before do
    UserFollower.create!(follower: current_user, followed: followed_user)

    allow(controller).to receive(:authenticate!).and_return(true)
    controller.instance_variable_set(:@current_user, current_user)
  end

  describe 'GET #history' do
    context 'when fetching the first page' do
      it 'returns the correct data and meta information' do
        get :history, params: { current_user_id: current_user.id, page_size: 2 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(2)
        expect(json_response['data'].first['id']).to eq(bed_time_histories.first.id)
        expect(json_response['data'].last['id']).to eq(bed_time_histories.last.id)


        expect(json_response['meta']['next_cursor']).to eq("#{bed_time_histories.last.sleep_duration}-#{bed_time_histories.last.id}")
        expect(json_response['meta']['page_size']).to eq(2)
      end
    end

    context 'when fetching the second page using a cursor' do
      it 'returns the remaining data and meta information' do
        cursor = "#{bed_time_histories.last.sleep_duration}-#{bed_time_histories.last.id}"
        get :history, params: { current_user_id: current_user.id, page_size: 2, cursor: cursor }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['id']).to eq(bed_time_histories[1].id)

        expect(json_response['meta']['next_cursor']).to be_nil
        expect(json_response['meta']['page_size']).to eq(2)
      end
    end

    context 'when there are no records' do
      it 'returns an empty data array' do
        BedTimeHistory.delete_all

        get :history, params: { current_user_id: current_user.id, page_size: 2 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_empty
        expect(json_response['meta']['next_cursor']).to be_nil
        expect(json_response['meta']['page_size']).to eq(2)
      end
    end
  end
end
