# frozen_string_literal: true

class BenchmarksController < ApplicationController
  before_action :prepare_comments

  def self.comments
    @comments ||= 1.upto(1000).map { |i| Comment.new(i, nil, "comment #{i}") }
  end

  def jb
  end

  def jbuilder
  end

  def simple_json_oj
    SimpleJson.json_module = SimpleJson::Json::Oj
  end

  def simple_json_as_json
    SimpleJson.json_module = ActiveSupport::JSON
  end

  private

  def prepare_comments
    n = params.fetch(:n, 100).to_i
    @comments = self.class.comments.take(n)
  end
end
