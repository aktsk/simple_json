# frozen_string_literal: true

require 'test_helper'

class MultipleViewPathsTest < ActionDispatch::IntegrationTest
  test 'The template correctly renders a JSON' do
    SimpleJson.template_paths = [
      'app/views',
      'app/simple_jsons'
    ]
    get '/posts_with_multiple_view_paths/1.json'

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
    SimpleJson.template_paths = ['app/views']
  end

  test 'The template correctly renders a JSON with template_cache enabled' do
    SimpleJson.enable_template_cache
    SimpleJson.template_paths = [
      'app/views',
      'app/simple_jsons'
    ]
    2.times do
      get '/posts_with_multiple_view_paths/1.json'

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
    SimpleJson.template_paths = ['app/views']
    SimpleJson.disable_template_cache
  end
end
