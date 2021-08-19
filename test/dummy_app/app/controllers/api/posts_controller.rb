# frozen_string_literal: true

if Rails::VERSION::MAJOR >= 5
  module Api
    class PostsController < ActionController::API
      include SimpleJson::SimpleJsonRenderable

      def show(id)
        @post = Post.find id
      end
    end
  end
end
