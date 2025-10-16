module Reply
  class AttemptsExhaustedError < StandardError
    EXHAUSTED_MESSAGE = "Retry attempts exhausted".freeze

    def initialize(exception_history:, message: nil)
      @exception_history = Array.wrap(exception_history)
      @summary           = message.presence || EXHAUSTED_MESSAGE
    end

    def messages
      "#{summary}: " + exception_history.map(&:message).join(", ")
    end

    private

    attr_reader :exception_history, :summary
  end
end
