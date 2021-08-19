# frozen_string_literal: true

require 'test_helper'

class SimpleJsonTest < ActionDispatch::IntegrationTest
  test 'The response will be cached' do
    Rails.cache.clear

    get '/posts_with_cache/1.json'
    cache = Rails.cache.read([SimpleJson.cache_key_prefix, 'posts', 1])

    assert_equal cache, {
      title: 'post 1',
      user: { name: 'user 1' },
      comments: [
        { body: 'comment 1' },
        { body: 'comment 2' },
        { body: 'comment 3' }
      ]
    }

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
    Rails.cache.clear
  end

  test 'The response will use cache' do
    Rails.cache.clear

    Rails.cache.write([SimpleJson.cache_key_prefix, 'posts', 1], {
                        title: 'post 1-cached',
                        user: { name: 'user 1' },
                        comments: [
                          { body: 'comment 1' },
                          { body: 'comment 2' },
                          { body: 'comment 3' }
                        ]
                      })

    get '/posts_with_cache/1.json'

    json = if response.respond_to?(:parsed_body)
             response.parsed_body
           else
             JSON.parse response.body
           end

    assert_equal json, {
      'title' => 'post 1-cached',
      'user' => { 'name' => 'user 1' },
      'comments' => [
        { 'body' => 'comment 1' },
        { 'body' => 'comment 2' },
        { 'body' => 'comment 3' }
      ]
    }
  ensure
    Rails.cache.clear
  end
end
