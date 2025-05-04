# frozen_string_literal: true

require 'benchmark/ips'

class BenchmarksController < ApplicationController
  def index(n = '100')
    @comments = 1.upto(n.to_i).map { |i| Comment.new(i, nil, "comment #{i}") }

    jb = render_to_string 'index_jb'
    jbuilder = render_to_string 'index_jbuilder'

    SimpleJson.json_module = SimpleJson::Json::Oj
    simple_json = render_to_string 'index'

    SimpleJson.json_module = ActiveSupport::JSON
    simple_json_active_support_json = render_to_string 'index'

    raise 'jb != jbuilder' unless jb == jbuilder
    raise 'simple_json != jbuilder' unless simple_json == jbuilder
    raise 'simple_json_active_support_json != jbuilder' unless simple_json_active_support_json == jbuilder

    result = Benchmark.ips do |x|
      x.report('jb') { render_to_string 'index_jb' }
      x.report('jbuilder') { render_to_string 'index_jbuilder' }
      x.report('simple_json(oj)') {
        SimpleJson.json_module = SimpleJson::Json::Oj
        render_to_string 'index'
      }
      x.report('simple_json(AS::json)') {
        SimpleJson.json_module = ActiveSupport::JSON
        render_to_string 'index'
      }
      x.compare!
    end
    render plain: result.data.to_s
  end
end
