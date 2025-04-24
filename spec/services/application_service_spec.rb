require 'rails_helper'

RSpec.describe ApplicationService, type: :service do
  let(:service) { described_class.new }

  describe '#with_retry_on_deadlock' do
    context 'when no deadlock occurs' do
      it 'executes the block successfully' do
        result = service.with_retry_on_deadlock { 'success' }
        expect(result).to eq('success')
      end
    end

    context 'when a deadlock occurs' do
      it 'retries the block up to 3 times and raises an error after max retries' do
        attempt_count = 0

        expect {
          service.with_retry_on_deadlock do
            attempt_count += 1
            raise ActiveRecord::Deadlocked if attempt_count <= 3
            'success'
          end
        }.to raise_error(StandardError, /Deadlock detected, max retry attempts reached/)

        expect(attempt_count).to eq(3)
      end
    end

    context 'when the block succeeds after retries' do
      it 'returns the result of the block' do
        attempt_count = 0

        result = service.with_retry_on_deadlock do
          attempt_count += 1
          raise ActiveRecord::Deadlocked if attempt_count < 3
          'success'
        end

        expect(result).to eq('success')
        expect(attempt_count).to eq(3)
      end
    end
  end
end
