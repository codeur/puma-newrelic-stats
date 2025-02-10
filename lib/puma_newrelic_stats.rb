# frozen_string_literal: true

require 'net/http'
require 'json'
require 'puma_newrelic_stats/version'
require 'puma_newrelic_stats/configuration'
require 'puma_newrelic_stats/collector'

module PumaNewrelicStats
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def start
      return if defined?(Puma) && Puma.respond_to?(:worker_index) && !Puma.worker_index.nil?

      Collector.new.start
    end
  end
end
