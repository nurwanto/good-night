require 'rails_helper'

RSpec.describe Api::V1::BedTimeService, type: :service do
  let(:current_user) { User.create!(name: 'Alice') }
  let(:follower_user) { User.create!(name: 'Bob') }
  let(:bed_time_history) do
    BedTimeHistory.create!(
      user_id: follower_user.id,
      bed_time: Time.now - 8.hours,
      wake_up_time: Time.now,
      sleep_duration: 480
    )
  end

  before do
    UserFollower.create!(follower: current_user, following: follower_user)
  end

  describe '#fetch_histories' do
    context 'when fetching bed time histories' do
      it 'returns the list of bed time histories with pagination' do
        params = { current_user_id: current_user.id, page_size: 10 }
        service = described_class.new(current_user, params)

        result = service.fetch_histories

        expect(result[:data]).to be_an(Array)
        expect(result[:pagination]).to include(:next_cursor, :previous_cursor, :page_size)
      end

      it 'applies cursor-based pagination' do
        params = { current_user_id: current_user.id, page_size: 1, page_after: "#{bed_time_history.sleep_duration}-#{bed_time_history.id}" }
        service = described_class.new(current_user, params)

        result = service.fetch_histories

        expect(result[:data]).to be_empty
        expect(result[:pagination][:next_cursor]).to be_nil
      end
    end

    context 'when no histories are found' do
      it 'returns an empty data array' do
        params = { current_user_id: current_user.id, page_size: 10 }
        service = described_class.new(current_user, params)

        result = service.fetch_histories

        expect(result[:data]).to eq([])
        expect(result[:pagination][:next_cursor]).to be_nil
        expect(result[:pagination][:previous_cursor]).to be_nil
      end
    end
  end

  describe '#set_sleep_time' do
    context 'when setting bed time' do
      it 'successfully sets the bed time' do
        params = { current_user_id: current_user.id, type: 'bed_time' }
        service = described_class.new(current_user, params)

        # Simulate the user waking up from the last history
        BedTimeHistory.create!(user_id: current_user.id, bed_time: Time.now - 8.hours, wake_up_time: Time.now)

        result = service.set_sleep_time

        expect(result).to be_a(Time)
        expect(BedTimeHistory.last.bed_time).to eq(result)
      end

      it 'raises an error if the user has not woken up yet' do
        params = { current_user_id: current_user.id, type: 'bed_time' }
        service = described_class.new(current_user, params)

        expect { service.set_sleep_time }.to raise_error(StandardError, "you haven't woken up yet")
      end
    end

    context 'when setting wake up time' do
      it 'successfully sets the wake up time' do
        params = { current_user_id: current_user.id, type: 'wake_up' }
        service = described_class.new(current_user, params)

        # Simulate the user going to bed
        BedTimeHistory.create!(user_id: current_user.id, bed_time: Time.now - 8.hours)

        result = service.set_sleep_time

        expect(result).to be_a(Time)
        expect(BedTimeHistory.last.wake_up_time).to eq(result)
      end

      it 'raises an error if the user has not slept yet' do
        params = { current_user_id: current_user.id, type: 'wake_up' }
        service = described_class.new(current_user, params)

        expect { service.set_sleep_time }.to raise_error(StandardError, "you haven't slept yet")
      end
    end

    context 'when the type is invalid' do
      it 'raises an error' do
        params = { current_user_id: current_user.id, type: 'invalid_type' }
        service = described_class.new(current_user, params)

        expect { service.set_sleep_time }.to raise_error(StandardError, 'invalid type, accepted value ["bed_time", "wake_up"]')
      end
    end
  end
end
