# frozen_string_literal: true

require 'benchmark/ips'

class BenchmarksController < ApplicationController
  def index(n = '100')
    @comments = 1.upto(n.to_i).map { |i| Comment.new(i, nil, "comment #{i}") }

    jb = render_to_string 'index_jb'
    jbuilder = render_to_string 'index_jbuilder'
    simple_json = render_to_string 'index_simple_json'
    raise 'jb != jbuilder' unless jb == jbuilder
    raise 'simple_json != jbuilder' unless simple_json == jbuilder

    result = Benchmark.ips do |x|
      x.report('jb') { render_to_string 'index_jb' }
      x.report('jbuilder') { render_to_string 'index_jbuilder' }
      x.report('simple_json') { render_to_string 'index_simple_json' }
      x.compare!
    end
    render plain: result.data.to_s
  end
end
