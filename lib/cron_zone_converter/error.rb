# frozen_string_literal: true

module CronZoneConverter
  class Error < ::RuntimeError
    attr_reader :original
    def initialize(message, original = nil)
      super(message)
      @original = original
    end
  end
end
