# frozen_string_literal: true

require 'test_helper'

class MigrationTest < ActionDispatch::IntegrationTest
  test 'The template correctly renders a JSON' do
    get '/simple_json_migration/posts/1.json'

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

  test 'render is successful when output is same' do
    get '/simple_json_migration/posts/1.json'

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

  test 'render fails when output is different' do
    assert_raises SimpleJson::Migratable::DifferentViewOutput do
      get '/simple_json_migration/posts_with_wrong_template/1.json'
    end
  end

  test 'simple_json uses jbuilder as partial when partial not exist' do
    get '/simple_json_migration/posts_without_partial/1.json'

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
end
