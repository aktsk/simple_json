# frozen_string_literal: true

require 'test_helper'

class SimpleJsonTest < ActionDispatch::IntegrationTest
  test 'The template correctly renders a JSON' do
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
  end

  test 'The template correctly renders a JSON with renderer cache' do
    SimpleJson.enable_template_cache
    2.times do
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
    end
  ensure
    SimpleJson.disable_template_cache
  end

  test 'render_partial returns an empty array for nil-collection' do
    get '/posts/2.json'

    json = if response.respond_to?(:parsed_body)
             response.parsed_body
           else
             JSON.parse response.body
           end

    assert_equal json, {
      'title' => 'post 2',
      'user' => { 'name' => 'user 1' },
      'comments' => []
    }
  end

  test ':plain handler still works' do
    get '/posts/hello'
    assert_equal 'hello', response.body
  end
end
