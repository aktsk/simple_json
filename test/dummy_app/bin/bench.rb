# frozen_string_literal: true

require 'action_dispatch/testing/integration'
require 'benchmark/ips'
require 'json'

SCENARIOS = [
  {
    label: 'jb',
    path: '/benchmarks/jb.json',
    decoder: ->(body) { JSON.parse(body) }
  },
  {
    label: 'jbuilder',
    path: '/benchmarks/jbuilder.json',
    decoder: ->(body) { JSON.parse(body) }
  },
  {
    label: 'simple_json(oj)',
    path: '/benchmarks/simple_json_oj.json',
    decoder: ->(body) { JSON.parse(body) }
  },
  {
    label: 'simple_json(AS::json)',
    path: '/benchmarks/simple_json_as_json.json',
    decoder: ->(body) { JSON.parse(body) }
  }
].freeze

SimpleJson.enable_template_cache

def perform_request(path, n:)
  session = ActionDispatch::Integration::Session.new(Rails.application)
  session.get(path, params: { n: n })
  raise "Unexpected status #{session.response.status} for #{path}" unless session.response.successful?
  session.response
end

def verify_payloads(n)
  baseline = SCENARIOS.first
  expected_response = perform_request(baseline[:path], n: n)
  expected_payload = baseline[:decoder].call(expected_response.body)

  SCENARIOS[1..].each do |scenario|
    response = perform_request(scenario[:path], n: n)
    if scenario[:media_type] && response.media_type != scenario[:media_type]
      raise "#{scenario[:label]} content type mismatch: #{response.media_type}"
    end

    actual_payload = scenario[:decoder].call(response.body)
    raise "#{scenario[:label]} payload mismatch" unless actual_payload == expected_payload
  end
end

def benchmark_requests(n)
  puts
  puts "* Rendering #{n} partials via render_to_string"

  verify_payloads(n)

  Benchmark.ips do |x|
    SCENARIOS.each do |scenario|
      x.report(scenario[:label]) do
        perform_request(scenario[:path], n: n)
      end
    end
    x.compare!
  end
end

puts 'SimpleJson Benchmark'
puts "ruby: #{RUBY_VERSION}"
puts "rails: #{Rails.version}"
puts "json: #{JSON::VERSION}"
puts "oj: #{Oj::VERSION}"
puts "----------------------"

[10, 100, 1000].each do |n|
  benchmark_requests(n)
end
