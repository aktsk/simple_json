# frozen_string_literal: true

require 'test_helper'

if Rails::VERSION::MAJOR >= 5

  class ActionControllerAPITest < ActionDispatch::IntegrationTest
    test 'The template correctly renders a JSON' do
      get '/api/posts/1.json'

      json = response.parsed_body

      assert_equal json, { 'title' => 'post 1' }
    end

    test 'The renamed template correctly renders a JSON' do
      get '/api/renamed_posts/1.json'

      json = response.parsed_body

      assert_equal json, { 'title' => 'post 1' }
    end
  end

end
