# frozen_string_literal: true

require 'test_helper'

class JsonModuleTest < ActionDispatch::IntegrationTest
  test 'The template correctly renders a JSON' do
    SimpleJson.json_module = ActiveSupport::JSON
    get '/posts/1.json'

    json = if response.respond_to?(:parsed_body)
             response.parsed_body
           else
             JSON.parse response.body
           end

    assert_equal json, {
      'title' => 'post 1',
      'user' => { 'name' => 'user 1' },
      'comments' => [
        { 'body' => 'comment 1' },
        { 'body' => 'comment 2' },
        { 'body' => 'comment 3' }
      ]
    }
  ensure
    SimpleJson.json_module = SimpleJson.config[:default_json_module]
  end
end
