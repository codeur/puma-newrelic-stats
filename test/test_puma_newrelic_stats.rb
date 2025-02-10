# frozen_string_literal: true

require 'test_helper'

class TestPumaNewrelicStats < Minitest::Test
  def setup
    PumaNewrelicStats.configuration = PumaNewrelicStats::Configuration.new
  end

  def test_it_has_a_version_number
    refute_nil PumaNewrelicStats::VERSION
  end

  def test_configuration_default_values
    config = PumaNewrelicStats::Configuration.new
    assert_equal 15, config.interval
    assert_equal 9293, config.control_port
    assert_equal "http://127.0.0.1:#{config.control_port}/puma/stats", config.control_url
  end

  def test_configure_block_sets_values
    PumaNewrelicStats.configure do |config|
      config.interval = 30
      config.control_port = 9000
      config.control_url = 'http://localhost:9000/stats'
    end

    assert_equal 30, PumaNewrelicStats.configuration.interval
    assert_equal 9000, PumaNewrelicStats.configuration.control_port
    assert_equal 'http://localhost:9000/stats', PumaNewrelicStats.configuration.control_url
  end

  def test_collector_calculates_totals
    collector = PumaNewrelicStats::Collector.new
    stats = {
      'worker_status' => [
        { 'last_status' => {
          'backlog' => 2,
          'running' => 3,
          'pool_capacity' => 4,
          'max_threads' => 5,
          'requests_count' => 100
        } },
        { 'last_status' => {
          'backlog' => 1,
          'running' => 2,
          'pool_capacity' => 3,
          'max_threads' => 5,
          'requests_count' => 50
        } }
      ]
    }

    totals = collector.send(:calculate_totals, stats)

    assert_equal 3, totals[:backlog]
    assert_equal 5, totals[:running]
    assert_equal 7, totals[:pool_capacity]
    assert_equal 10, totals[:max_threads]
    assert_equal 150, totals[:requests_count]
  end

  def test_collector_handles_single_mode_stats
    collector = PumaNewrelicStats::Collector.new
    stats = {
      'backlog' => 2,
      'running' => 3,
      'pool_capacity' => 4,
      'max_threads' => 5,
      'requests_count' => 100
    }

    totals = collector.send(:calculate_totals, stats)

    assert_equal 2, totals[:backlog]
    assert_equal 3, totals[:running]
    assert_equal 4, totals[:pool_capacity]
    assert_equal 5, totals[:max_threads]
    assert_equal 100, totals[:requests_count]
  end

  def test_start_does_not_start_collector_in_worker
    # Simulate being in a Puma worker
    Object.const_set(:Puma, Module.new) unless defined?(Puma)
    def Puma.worker_index
      0
    end

    collector_thread = PumaNewrelicStats.start
    assert_nil collector_thread

    # Clean up
    Puma.singleton_class.remove_method(:worker_index)
  end
end
