require 'rails_helper'

RSpec.describe Api::V1::UserService, type: :service do
  let(:current_user) { User.create!(name: 'Alice') }
  let(:follower_user) { User.create!(name: 'Bob') }
  let(:following_user) { User.create!(name: 'Charlie') }
  let(:target_user) { User.create!(name: 'David') }

  before do
    UserFollower.create!(follower: follower_user, following: current_user)
    UserFollower.create!(follower: current_user, following: following_user)
  end

  describe '#fetch_relations' do
    context 'when fetching followers' do
      it 'returns the list of followers with pagination' do
        params = { relation_type: 'followers', page_size: 10 }
        service = described_class.new(current_user, params)

        result = service.fetch_relations

        expect(result[:data].size).to eq(1)
        expect(result[:data].first.id).to eq(follower_user.id)
        expect(result[:pagination][:next_cursor]).to be_nil
        expect(result[:pagination][:previous_cursor]).to be_nil
        expect(result[:pagination][:per_page]).to eq(10)
      end
    end

    context 'when fetching following' do
      it 'returns the list of following users with pagination' do
        params = { relation_type: 'following', page_size: 10 }
        service = described_class.new(current_user, params)

        result = service.fetch_relations

        expect(result[:data].size).to eq(1)
        expect(result[:data].first.id).to eq(following_user.id)
        expect(result[:pagination][:next_cursor]).to be_nil
        expect(result[:pagination][:previous_cursor]).to be_nil
        expect(result[:pagination][:per_page]).to eq(10)
      end
    end

    context 'when relation_type is invalid' do
      it 'raises an error' do
        params = { relation_type: 'invalid_type', page_size: 10 }
        service = described_class.new(current_user, params)

        expect { service.fetch_relations }.to raise_error(StandardError, 'invalid relation_type, accepted relation_type value ["followers", "following"]')
      end
    end
  end

  describe '#create_relations' do
    context 'when following a user' do
      it 'successfully follows the target user' do
        params = { user_action: 'follow', target_user_id: target_user.id }
        service = described_class.new(current_user, params)

        expect { service.create_relations }.to change { UserFollower.count }.by(1)
      end

      it 'raises an error if already following the user' do
        UserFollower.create!(follower: current_user, following: target_user)
        params = { user_action: 'follow', target_user_id: target_user.id }
        service = described_class.new(current_user, params)

        expect { service.create_relations }.to raise_error(StandardError, "you are already following user #{target_user.id}")
      end
    end

    context 'when unfollowing a user' do
      it 'successfully unfollows the target user' do
        UserFollower.create!(follower: current_user, following: target_user)
        params = { user_action: 'unfollow', target_user_id: target_user.id }
        service = described_class.new(current_user, params)

        expect { service.create_relations }.to change { UserFollower.count }.by(-1)
      end

      it 'raises an error if not following the user' do
        params = { user_action: 'unfollow', target_user_id: target_user.id }
        service = described_class.new(current_user, params)

        expect { service.create_relations }.to raise_error(StandardError, "you are not following user #{target_user.id}")
      end
    end

    context 'when target_user_id is missing' do
      it 'raises an error' do
        params = { user_action: 'follow' }
        service = described_class.new(current_user, params)

        expect { service.create_relations }.to raise_error(StandardError, 'target_user_id should be exist')
      end
    end

    context 'when user_action is invalid' do
      it 'raises an error' do
        params = { user_action: 'invalid_action', target_user_id: target_user.id }
        service = described_class.new(current_user, params)

        expect { service.create_relations }.to raise_error(StandardError, 'invalid user_actions, accepted user_action value ["follow", "unfollow"]')
      end
    end
  end
end
