# frozen_string_literal: true

module PumaNewrelicStats
  class Configuration
    attr_accessor :control_url, :interval, :control_port

    def initialize
      @interval = 15
      @control_port = 9293
      @control_url = "http://127.0.0.1:#{@control_port}/puma/stats"
    end
  end
end
