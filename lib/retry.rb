module Retry
  def attempt(*exceptions, delay: 0, reattempts: 2)
    attempts_remaining = reattempts.to_i + 1
    exception_history  = []
    rescue_from        = (exceptions.presence || [StandardError]).freeze

    begin
      yield
    rescue *rescue_from => e
      exception_history.push(e)
      attempts_remaining -= 1
      sleep(delay.to_f) if delay.present?
      retry if attempts_remaining.positive?

      raise(RetryExhaustedError.new(exception_history:)
    end
  end

  module_function :attempt
end

require_relative 'retry/attempts_exhausted_error'
