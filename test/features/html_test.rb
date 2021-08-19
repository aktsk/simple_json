# frozen_string_literal: true

require 'test_helper'

class SimpleJsonTest < ActionDispatch::IntegrationTest
  test 'bypass simple_json when HTML requested' do
    get '/posts/1.html'

    assert_includes response.body, "HTML for post 1"
  end
end
