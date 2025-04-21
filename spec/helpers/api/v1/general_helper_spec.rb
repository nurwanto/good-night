require 'rails_helper'

RSpec.describe Api::V1::GeneralHelper, type: :helper do
  describe '#authenticate!' do
    let(:user) { User.create!(name: 'Test User') }

    context 'when current_user_id is not provided' do
      it 'raises an ArgumentError' do
        expect { helper.authenticate! }.to raise_error(ArgumentError, 'current_user_id should be exist')
      end
    end

    context 'when current_user_id is provided but user does not exist' do
      it 'raises a StandardError' do
        allow(helper).to receive(:params).and_return({ current_user_id: 9999 }) # Non-existent user ID
        expect { helper.authenticate! }.to raise_error(StandardError, 'Authentication failed, user_id 9999 not exist')
      end
    end

    context 'when current_user_id is provided and user exists' do
      it 'returns the user' do
        allow(helper).to receive(:params).and_return({ current_user_id: user.id })
        expect(helper.authenticate!).to eq(user)
      end
    end
  end
end
