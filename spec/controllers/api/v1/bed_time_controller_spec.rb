require 'rails_helper'

RSpec.describe Api::V1::BedTimeController, type: :controller do
  let(:current_user) { User.create!(name: 'Alice') }
  let(:bed_time_history) do
    BedTimeHistory.create!(
      user_id: current_user.id,
      bed_time: Time.now - 8.hours,
      wake_up_time: Time.now,
      sleep_duration_in_sec: 480
    )
  end

  before do
    # Authenticate the current user
    allow(controller).to receive(:authenticate!).and_return(true)
    controller.instance_variable_set(:@current_user, current_user)
  end

  describe 'GET #history' do
    context 'when fetching bed time histories' do
      it 'returns the list of bed time histories with pagination' do
        allow_any_instance_of(Api::V1::BedTimeService).to receive(:fetch_histories).and_return(
          {
            data: [
              {
                id: bed_time_history.id,
                user_id: bed_time_history.user_id,
                bed_time: bed_time_history.bed_time,
                wake_up_time: bed_time_history.wake_up_time,
                duration: bed_time_history.sleep_duration_in_sec
              }
            ],
            pagination: {
              next_cursor: nil,
              previous_cursor: nil,
              per_page: 10
            }
          }
        )

        get :history, params: { current_user_id: current_user.id, page_size: 10 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['id']).to eq(bed_time_history.id)
        expect(json_response['pagination']['next_cursor']).to be_nil
        expect(json_response['pagination']['previous_cursor']).to be_nil
        expect(json_response['pagination']['per_page']).to eq(10)
      end
    end

    context 'when an exception is raised' do
      it 'returns an error message' do
        allow_any_instance_of(Api::V1::BedTimeService).to receive(:fetch_histories).and_raise(StandardError, 'Something went wrong')

        get :history, params: { current_user_id: current_user.id, page_size: 10 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('Something went wrong')
      end
    end
  end

  describe 'POST #set_unset' do
    context 'when setting a sleep time' do
      it 'successfully sets the sleep time' do
        allow_any_instance_of(Api::V1::BedTimeService).to receive(:set_sleep_time).and_return(Time.now)

        post :set_unset, params: { current_user_id: current_user.id, type: 'bed_time' }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to match(/bed_time successfully set at/)
      end
    end

    context 'when an exception is raised' do
      it 'returns an error message' do
        allow_any_instance_of(Api::V1::BedTimeService).to receive(:set_sleep_time).and_raise(StandardError, 'Something went wrong')

        post :set_unset, params: { current_user_id: current_user.id, type: 'bed_time' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('Something went wrong')
      end
    end

    context 'when an ArgumentError is raised' do
      it 'returns an error message' do
        allow_any_instance_of(Api::V1::BedTimeService).to receive(:set_sleep_time).and_raise(ArgumentError, 'Invalid argument')

        post :set_unset, params: { current_user_id: current_user.id, type: 'invalid_type' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq('Invalid argument')
      end
    end

    context 'when type parameter is invalid' do
      it 'returns an error message' do
        post :set_unset, params: { current_user_id: current_user.id, type: 'invalid_type' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['error_message']).to eq("invalid type, accepted value [\"bed_time\", \"wake_up\"]")
      end
    end
  end
end
