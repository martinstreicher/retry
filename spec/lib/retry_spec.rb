# frozen_string_literal: true

require_relative '../../lib/retry'

RSpec.describe Retry, :aggregate_failures, type: :unit do
  context "when retrying a block" do
    it "reattempts using the default of StandardError" do
      expect { Retry.attempt { raise StandardError } }
        .to raise_error(Retry::AttemptsExhaustedError)
    end
  end
end
