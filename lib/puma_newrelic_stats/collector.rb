# frozen_string_literal: true

module PumaNewrelicStats
  class Collector
    def start
      Thread.new do
        loop do
          collect_metrics
          sleep PumaNewrelicStats.configuration.interval
        end
      end
    end

    private

    def fetch_puma_stats
      url = URI(PumaNewrelicStats.configuration.control_url)
      response = Net::HTTP.get(url)
      JSON.parse(response)
    rescue StandardError => e
      NewRelic::Agent.logger.error("Error fetching Puma stats: #{e.message}")
    end

    def collect_metrics
      stats = fetch_puma_stats
      return unless stats

      totals = calculate_totals(stats)
      record_metrics(totals)
    rescue StandardError => e
      NewRelic::Agent.logger.error("Error recording Puma stats: #{e.message}")
    end

    def calculate_totals(stats)
      totals = { backlog: 0, running: 0, pool_capacity: 0, max_threads: 0, requests_count: 0 }

      if stats['worker_status'] # Cluster mode
        stats['worker_status'].each do |worker|
          last_status = worker['last_status'] || {}
          update_totals(totals, last_status)
        end
      else # Single mode
        update_totals(totals, stats)
      end

      totals
    end

    def update_totals(totals, status)
      totals[:backlog] += status['backlog'].to_i
      totals[:running] += status['running'].to_i
      totals[:pool_capacity] += status['pool_capacity'].to_i
      totals[:max_threads] += status['max_threads'].to_i
      totals[:requests_count] += status['requests_count'].to_i
    end

    def record_metrics(totals)
      NewRelic::Agent.record_metric('Custom/Puma/Total/Backlog', totals[:backlog])
      NewRelic::Agent.record_metric('Custom/Puma/Total/RunningThreads', totals[:running])
      NewRelic::Agent.record_metric('Custom/Puma/Total/PoolCapacity', totals[:pool_capacity])
      NewRelic::Agent.record_metric('Custom/Puma/Total/MaxThreads', totals[:max_threads])
      NewRelic::Agent.record_metric('Custom/Puma/Total/RequestsCount', totals[:requests_count])
    end
  end
end
